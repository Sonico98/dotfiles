#!/bin/bash
set -euo pipefail

LOCKSCREEN_DIR=/tmp/lockscreen

export XSECURELOCK_FONT="Kosefont JP"
export XSECURELOCK_AUTH_BACKGROUND_COLOR=black
export XSECURELOCK_AUTH_FOREGROUND_COLOR=white
export XSECURELOCK_PASSWORD_PROMPT=kaomoji
export XSECURELOCK_COMPOSITE_OBSCURER=0
export XSECURELOCK_AUTH_TIMEOUT=5
export XSECURELOCK_BLANK_TIMEOUT=10
export XSECURELOCK_BLANK_DPMS_STATE=off
export XSECURELOCK_SHOW_KEYBOARD_LAYOUT=0
export XSECURELOCK_SAVER=/home/sonico/.bins/.scripts/lockscreen/saver.sh

if [ -z ${LOCKSCREEN_DIR+x} ]; then exit 1; fi # bail if lockscreen dir is not set


# This is done already on i3wm's config file
# but this condition is present so an image is shown
# when invoked from some other program as well (xidlehook)
if [[ ! -d ${LOCKSCREEN_DIR} ]]; then
	mkdir -p ${LOCKSCREEN_DIR}
	scrot -o ${LOCKSCREEN_DIR}/lock.png
	convert ${LOCKSCREEN_DIR}/lock.png -scale 10% -blur 0x1.5 -resize 1000% ${LOCKSCREEN_DIR}/lockscreen.jpg 
fi

# xset dpms force off

# Pause music and mute audio with pulseaudio-control
~/.config/polybar/scripts/player-mpris-tail.py pause &
pulseaudio-control mute
xsecurelock
pulseaudio-control unmute
rm -rf ${LOCKSCREEN_DIR}
