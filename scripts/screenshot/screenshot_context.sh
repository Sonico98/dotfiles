#!/bin/bash
fullfile="/tmp/scrotfull.png"
file="/tmp/scrot.png"
screen_width="$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f1)"
# Get current cursor coordinates and store them in variables X and Y
eval "$(xdotool getmouselocation --shell)"
scrot -o -d 3 "$fullfile"
xdotool mousemove --sync "$screen_width" 0 click 1 sleep 0.1
feh -x -F "$fullfile" &
feh_pid=$!
xdotool mousemove --sync "$X" "$Y"
scrot -o -s "$file"
kill "$feh_pid"
xdotool mousemove --sync "$X" "$Y" sleep 0.1
xdotool click 3
copyq write image/png - < "$file"
copyq select 0
rm -f "$fullfile"
rm -f "$file"
