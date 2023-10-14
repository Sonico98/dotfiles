#!/bin/bash
set -euo pipefail

LOCKSCREEN_DIR=/tmp/lockscreen
if [ -z ${LOCKSCREEN_DIR+x} ]; then exit 1; fi # bail if lockscreen dir is not set

if [[ ! -d ${LOCKSCREEN_DIR} ]]; then
	mkdir -p ${LOCKSCREEN_DIR}
	grim -t png -l 0 ${LOCKSCREEN_DIR}/lock.png
	convert ${LOCKSCREEN_DIR}/lock.png -scale 10% -blur 0x1.5 -resize 1000% ${LOCKSCREEN_DIR}/lockscreen.jpg
fi

# Pause music, mute audio and microphone
playerctl --player=%any,chromium pause
wpctl set-mute @DEFAULT_AUDIO_SINK@ 1
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1
swaylock -F --indicator-idle-visible -i ${LOCKSCREEN_DIR}/lockscreen.jpg
wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0
rm -rf ${LOCKSCREEN_DIR}
