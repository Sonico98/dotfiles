#!/usr/bin/env bash

FILE_PATH="$1"			# Full path of the previewed file
PREVIEW_X_COORD="$2"		# x coordinate of upper left cell of preview area
PREVIEW_Y_COORD="$3"
PREVIEW_WIDTH="$4"		# Width of the preview pane (number of fitting characters)
PREVIEW_HEIGHT="$5"		# Height of the preview pane (number of fitting characters)

tmsu_tag_list() {
	taglist="$(exiftool -q -q -Keywords "$FILE_PATH" | cut -d':' -f2 | xargs)"
    result=$?
    if [ $result -eq 0 ]; then
        if ! [ -z "$taglist" ]; then
            echo "Tags: $taglist" | fold -s -w "$1"
        fi
    fi
}

mimetype=$(file --mime-type -Lb "$FILE_PATH")

function kclear {
	kitty +kitten icat \
		--transfer-mode=file \
		--clear 2>/dev/null
}

function kclear_t {
	kitty +kitten icat \
		--transfer-mode=stream \
		--clear 2>/dev/null
}

function image {
	kclear
	kitty +kitten icat \
		--transfer-mode=file \
		--place "${PREVIEW_WIDTH}x${PREVIEW_HEIGHT}@${PREVIEW_X_COORD}x${PREVIEW_Y_COORD}" \
		"$1" 2>/dev/null
}

case "$mimetype" in
	audio/*)
		kclear_t
		# Place the picture at the screen bottom corner, then resize it
		# Works fine in a ~1366x768 window (laptop screen)
		# Values should be tweaked for other screen sizes
		PREVIEW_Y_COORD="$(( "$PREVIEW_HEIGHT" - "$PREVIEW_HEIGHT"/3 ))"
		PREVIEW_X_COORD="$(( "$PREVIEW_WIDTH"/2 + "$PREVIEW_WIDTH" + 4 ))"
		PREVIEW_HEIGHT="$(( "$PREVIEW_HEIGHT" - ("$PREVIEW_HEIGHT"/2) - 3 ))"

		has_cover="$(exiftool -q -q "$FILE_PATH" 2>/dev/null | grep -Eq '(Cover Art|CoverArt|Picture)')"
		if [ "$?" -eq 0 ]; then
			exiftool -b -CoverArt -Picture "$FILE_PATH" 2>/dev/null | \
				kitty +kitten icat --transfer-mode=stream --place \
				"${PREVIEW_WIDTH}x${PREVIEW_HEIGHT}@${PREVIEW_X_COORD}x${PREVIEW_Y_COORD}"
		fi
		;;
	image/*)
		# Calculate the offset
		dimension="Size: $(exiftool -q -q -ImageSize "$FILE_PATH" | awk '{print $4}')"
        tags=$(tmsu_tag_list "$PREVIEW_WIDTH")
		header="$(echo "$dimension" && echo "$tags")"
		header_length="$(echo "$header" | wc -l)"
		# Place the image below the header (+ 1 to add some spacing between the header and the image)
		PREVIEW_Y_COORD="$(( "$PREVIEW_Y_COORD" + ("$header_length") + 1 ))" 
		# -1 to avoid the image from getting out of the box
		PREVIEW_HEIGHT="$(( "$PREVIEW_HEIGHT" - ("$header_length") - 1 ))"

		# Preview the picture. Use its thumbnail for faster processing
		thumbnail="$(allmytoes -sx "$FILE_PATH" 2>/dev/null)"
		if [ "$thumbnail" ]; then
			image "${thumbnail}"
		else
			kclear
		fi
		;;
	application/pdf)
		kclear_t
		# Calculate the offset
		pages="Page count: $(exiftool -q -q -PageCount "$FILE_PATH" | awk '{print $4}')"
		header_length="$(echo "$pages" | wc -l)"
		PREVIEW_HEIGHT="$(( "$PREVIEW_HEIGHT" - ("$header_length") - 1 ))"
		PREVIEW_Y_COORD="$(( "$PREVIEW_Y_COORD" + ("$header_length") + 1 ))"

		# Preview the first page
		convert "$FILE_PATH"[0] -alpha remove -background white jpg:- 2>/dev/null | \
			kitty +kitten icat --transfer-mode=stream --place \
			"${PREVIEW_WIDTH}x${PREVIEW_HEIGHT}@${PREVIEW_X_COORD}x${PREVIEW_Y_COORD}"
		;;
	video/*)
		kclear_t
		# Calculate the offset
		filename="$(basename "$FILE_PATH")"
		dimension="Size: $(exiftool -ImageSize "$FILE_PATH" | awk '{print $4}')"
		header="$(echo "$filename" && echo "$dimension")"
		header_length="$(echo "$header" | wc -l)"
		PREVIEW_HEIGHT="$(( "$PREVIEW_HEIGHT" - ("$header_length") - 1 ))"
		PREVIEW_Y_COORD="$(( "$PREVIEW_Y_COORD" + ("$header_length") + 1 ))"

		# Preview a thumbnail
		# We execute the command in a subshell to prevent errors from breaking the TUI
		( (ffmpegthumbnailer -i "$FILE_PATH" -f -m -c png -s 512 -o - | \
			kitty +kitten icat --transfer-mode=stream --place \
			"${PREVIEW_WIDTH}x${PREVIEW_HEIGHT}@${PREVIEW_X_COORD}x${PREVIEW_Y_COORD}") 2>/dev/null )
		;;
	*)
		kclear
		kclear_t
		exit
		;;
esac
