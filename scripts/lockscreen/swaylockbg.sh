#!/bin/bash
# Exit if the screen is already locked
if pidof swaylock; then
	exit 1
fi

set -euo pipefail
pause_autocalib="busctl --expect-reply=false --user set-property org.clight.clight /org/clight/clight/Conf/Backlight org.clight.clight.Conf.Backlight NoAutoCalib 'b'"

LOCKSCREEN_DIR=/tmp/lockscreen
if [ -z ${LOCKSCREEN_DIR+x} ]; then exit 1; fi # bail if lockscreen dir is not set

if [[ ! -d ${LOCKSCREEN_DIR} ]]; then
	mkdir -p ${LOCKSCREEN_DIR}
	grim -t png -l 0 ${LOCKSCREEN_DIR}/lock.png
	convert ${LOCKSCREEN_DIR}/lock.png -scale 10% -blur 0x1.5 -resize 1000% ${LOCKSCREEN_DIR}/lockscreen.jpg
fi

# Pause music and brightness auto-calibration, mute audio and microphone.
playerctl --player=%any,chromium pause
wpctl set-mute @DEFAULT_AUDIO_SINK@ 1
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1
eval "$pause_autocalib" true
# Turn the screen off after five seconds, 
# turn it back on when activity is detected 
# and automatically set the screen brightness
swayidle timeout 5 'swaymsg "output * power off"' resume \
	'swaymsg "output * power on" && busctl --expect-reply=false --user call org.clight.clight /org/clight/clight org.clight.clight Capture "bb" true false' &
idlepid=$!
swaylock -F --indicator-idle-visible -i ${LOCKSCREEN_DIR}/lockscreen.jpg
# Undo the previous actions after the screen has been unlocked
eval "$pause_autocalib" false
wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0
kill "$idlepid"
rm -rf ${LOCKSCREEN_DIR}
