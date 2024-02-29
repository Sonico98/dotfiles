#!/bin/bash
# Options
ADD_WHITE_BORDER=0 			# 0 Disabled, 1 Enabled
WHITE_BORDER_OPACITY=100 	# Only useful if ADD_WHITE_BORDER is 1. Number from 1 to 100.
QUANTISIZE=0 				# 0 Disabled, 1 Enabled. Reduces image file size at the cost of quality


# -- Script start --------------------------------


get_dominant_color()
{
	convert "$1" -brightness-contrast 15x5 -scale 50x50! -depth 8 +dither -colors 8 -format "%c" histogram:info: \
		| sed -n 's/^[ ]*\(.*\):.*[#]\([0-9a-fA-F]*\) .*$/\1,#\2/p' \
		| sort -r -n -k 1 -t "," | cut -d',' -f2 | head -1
}


style_image()
{
	op=0
	if [ $ADD_WHITE_BORDER -eq 1 ]; then
		op="$WHITE_BORDER_OPACITY"
	fi

	MAGICK_OCL_DEVICE=true magick "$1" \
	  \( +clone -alpha extract \
	    -draw 'fill black polygon 0,0 0,13 13,0 fill white circle 13,13 13,0' \
	    \( +clone -flip \) -compose Multiply -composite \
	    \( +clone -flop \) -compose Multiply -composite \
	  \) -alpha off -compose CopyOpacity -composite \
	  \( -clone 0 -fill White -colorize "$op" \) \
	  \( -clone 0 -alpha extract -virtual-pixel black -morphology edgein octagon:2  \) \
	  -compose over -composite \
	  \( +clone -background black -shadow 60x10+0+8 \) \
	  +swap -background "$(get_dominant_color "$file")" -layers merge +repage "$file"
	  # \( +clone -background black -shadow 53x16+0+10 \) \
}

# Screenshot the whole screen, open the image in full screen, then select a region
dunstctl set-paused true
grim -t png -l 0 -o "$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')" /tmp/full.png
swayimg -f /tmp/full.png &
swayimg_pid=$!

file=/tmp/scrshot.png
grim -t png -l 0 -g "$(swaymsg -t get_tree | jq -r 'recurse(.nodes[]?, .floating_nodes[]?) | select(.visible or (.type == "output" and .active)) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | slurp -b 2b2a2f7a -c f28b82)" "$file"
success=$?
kill "$swayimg_pid"
rm -f /tmp/full.png
dunstctl set-paused false

if [[ $success -eq 0 ]]; then
	# Copy raw image
	wl-copy -t image/png < "$file"

	# Round corners and add shadow
	style_image "$file"
	
	# Convert to 8bit PNG, to avoid weird effects and reduce file size
	if [ "$QUANTISIZE" -eq 1 ]; then
		pngquant "$file" -f -o "$file"
	fi

	# Copy and save the edited screenshot
	wl-copy -t image/png < "$file"

	# Finish
	notify-send 'Grim' 'Screenshot taken'
	sleep 2 && rm -f "$file"
	exit 0
fi
