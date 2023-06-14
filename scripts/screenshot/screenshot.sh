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
	  \( +clone -background black -shadow 100x40+0+16 \) \
	  +swap -background "$(get_dominant_color "$file")" -layers merge +repage "$file"
	  # \( +clone -background black -shadow 53x16+0+10 \) \
}

file=/tmp/scrshot.png
# Required so scrot starts properly
sleep 0.2
scrot -o -s -f --line style=solid,width=4,color="red",opacity=100,mode=classic -q 100 "$file"
success=$?

if [[ $success -eq 0 ]]; then
	# Copy raw image, but don't save it on copyq's history
	copyq copy image/png - < "$file"

	# Round corners and add shadow
	style_image "$file"
	
	# Convert to 8bit PNG, to avoid weird effects and reduce file size
	if [ "$QUANTISIZE" -eq 1 ]; then
		pngquant "$file" -f -o "$file"
	fi

	# Copy and save the edited screenshot on copyq, also select it
	copyq write image/png - < "$file"
	copyq select 0

	# Finish
	notify-send 'Scrot' 'Screenshot taken'
	rm -f "$file"
	exit 0
fi
