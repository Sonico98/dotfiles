#!/bin/bash

# Undo the previous actions after the screen has been unlocked
# eval busctl --expect-reply=false --user set-property org.clight.clight /org/clight/clight/Conf/Backlight org.clight.clight.Conf.Backlight NoAutoCalib 'b' false || true
wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 || true
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0 || true
dunstctl set-paused false || true
kill "$(cat $LOCKSCREEN_DIR/idlepid)"
rm -rf ${LOCKSCREEN_DIR}
