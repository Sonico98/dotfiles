#!/bin/bash
# Exit if the screen is already locked
if pidof swaylock; then
	exit 1
fi

set -euo pipefail
pause_autocalib="busctl --expect-reply=false --user set-property org.clight.clight /org/clight/clight/Conf/Backlight org.clight.clight.Conf.Backlight NoAutoCalib 'b'"

LOCKSCREEN_DIR=/tmp/lockscreen
mkdir -p ${LOCKSCREEN_DIR}

# if [[ ! -d ${LOCKSCREEN_DIR} ]]; then
# 	mkdir -p ${LOCKSCREEN_DIR}
# 	grim -t png -l 0 ${LOCKSCREEN_DIR}/lock.png
# 	magick ${LOCKSCREEN_DIR}/lock.png -scale 10% -blur 0x1.5 -clamp -resize 1000% ${LOCKSCREEN_DIR}/lockscreen.jpg
# fi

LOCKARGS=""
for OUTPUT in `swaymsg -t get_outputs | jq -r '.[] | select(.active) | .name'`
do
	IMAGE=$LOCKSCREEN_DIR/$OUTPUT-lock.png
	grim -t png -l 0 -o $OUTPUT $IMAGE
	magick $IMAGE -scale 10% -blur 0x1.5 -clamp -resize 1000% $IMAGE
	LOCKARGS="${LOCKARGS} -i ${OUTPUT}:${IMAGE}"
	rm -f $LOCKSCREEN_DIR/o.png
done

# Pause music and brightness auto-calibration, mute audio and microphone.
playerctl --player=%any,firefox pause || true
wpctl set-mute @DEFAULT_AUDIO_SINK@ 1 || true
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1 || true
# eval "$pause_autocalib" true || true
dunstctl set-paused true || true
# Turn the screen off after five seconds, 
# turn it back on when activity is detected 
# and automatically set the screen brightness
swayidle timeout 5 'swaymsg "output * power off"' resume \
	'swaymsg "output * power on"' &
idlepid=$!
swaylock -F --indicator-idle-visible $LOCKARGS
# Undo the previous actions after the screen has been unlocked
# eval "$pause_autocalib" false || true
wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 || true
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0 || true
dunstctl set-paused false || true
kill "$idlepid"
rm -rf ${LOCKSCREEN_DIR}
