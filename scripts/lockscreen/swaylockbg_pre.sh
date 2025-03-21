#!/bin/bash

LOCKSCREEN_DIR=/tmp/lockscreen
mkdir -p ${LOCKSCREEN_DIR}

LOCKARGS=""
for OUTPUT in `swaymsg -t get_outputs | jq -r '.[] | select(.active) | .name'`
do
	IMAGE=$LOCKSCREEN_DIR/$OUTPUT-lock.png
	grim -t png -l 0 -o $OUTPUT $IMAGE
	magick $IMAGE -scale 10% -blur 0x1.5 -clamp -resize 1000% $IMAGE
	LOCKARGS="${LOCKARGS} -i ${OUTPUT}:${IMAGE}"
	rm -f $LOCKSCREEN_DIR/o.png
done
touch "$LOCKSCREEN_DIR"/lockargs
echo "$LOCKARGS" >| "$LOCKSCREEN_DIR"/lockargs

# Pause music and brightness auto-calibration, mute audio and microphone.
playerctl --player=%any,firefox pause || true
wpctl set-mute @DEFAULT_AUDIO_SINK@ 1 || true
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1 || true
# eval busctl --expect-reply=false --user set-property org.clight.clight /org/clight/clight/Conf/Backlight org.clight.clight.Conf.Backlight NoAutoCalib 'b' true || true
dunstctl set-paused true || true
