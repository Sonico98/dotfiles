#!/bin/bash

# Exit if the screen is already locked
if pidof swaylock; then
	exit 1
fi

# Turn the screen off after five seconds, 
# turn it back on when activity is detected 
# and automatically set the screen brightness
swayidle timeout 5 'swaymsg "output * power off"' resume \
	'swaymsg "output * power on"' &

IDLEPID=$!
touch $LOCKSCREEN_DIR/idlepid
echo "$IDLEPID" >| "$LOCKSCREEN_DIR"/idlepid

LOCKARGS=$(cat $LOCKSCREEN_DIR/lockargs)
swaylock -F --indicator-idle-visible $LOCKARGS
