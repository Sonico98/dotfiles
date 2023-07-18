#!/usr/bin/env bash

test -z "$joshuto_wrap_id" && exit 1;

FILE_PATH="$1"			# Full path of the previewed file
X_COORD="$2"	# x coordinate of upper left cell of preview area
Y_COORD="$3"    # x coordinate of upper left cell of preview area
WIDTH="$4"		# Width of the preview pane (number of fitting characters)
HEIGHT="$5"		# Height of the preview pane (number of fitting characters)

mimetype=$(file --mime-type -Lb "$FILE_PATH")

case "$mimetype" in
	audio/*)
		remove_image
		random_name="$(cksum "$FILE_PATH" | cut -d ' ' -f1)"
		# Place the picture at the screen bottom corner
		# Works fine in a ~1366x768 window (laptop screen)
		# Values should be tweaked for other screen sizes
		HEIGHT="$(( "$HEIGHT" - ("$HEIGHT"/2) - 3 ))"
		Y_COORD="$(( "$HEIGHT" + "$HEIGHT" - "$HEIGHT"/3 ))"
		X_COORD="$(( "$WIDTH" + "$WIDTH" - "$WIDTH"/6 ))"

		has_cover="$(exiftool -q -q "$FILE_PATH" 2>/dev/null | grep -Eq '(Cover Art|CoverArt|Picture)')"
		if [ "$?" -eq 0 ]; then
			exiftool -b -CoverArt -Picture "$FILE_PATH" 1>|/tmp/"$random_name"_coverart 2>/dev/null
			show_image /tmp/"$random_name"_coverart "$X_COORD" "$Y_COORD" "$WIDTH" "$HEIGHT"
			rm -f /tmp/"$random_name"_coverart
		fi
		;;
	image/*)
		remove_image
		# Calculate the offset
		meta_file="$(get_preview_meta_file "$FILE_PATH")"
		y_offset="$(cat "$meta_file" | grep "y-offset" | awk '{print $2}')"
        Y_COORD="$(( "$Y_COORD" + "$y_offset" ))"
		HEIGHT="$(( "$HEIGHT" - ("$y_offset") - 1 ))"

		# Preview the picture. Use its thumbnail for faster processing
		thumbnail="$(allmytoes -sx "$FILE_PATH" 2>/dev/null)"
		if [ "$thumbnail" ]; then
			show_image "${thumbnail}" "$X_COORD" "$Y_COORD" "$WIDTH" "$HEIGHT"
		else
			remove_image
		fi
		;;
	application/pdf)
		remove_image
		random_name="$(cksum "$FILE_PATH" | cut -d ' ' -f1)"
		# Calculate the offset
		pages="Page count: $(exiftool -q -q -PageCount "$FILE_PATH" | awk '{print $4}')"
		header_length="$(echo "$pages" | wc -l)"
		HEIGHT="$(( "$HEIGHT" - ("$header_length") - 1 ))"
		Y_COORD="$(( "$Y_COORD" + ("$header_length") + 1 ))"

		# Preview the first page
		convert "$FILE_PATH"[0] -alpha remove -background white \
			jpg:/tmp/"$random_name"_first_page 2>/dev/null
		show_image /tmp/"$random_name"_first_page "$X_COORD" "$Y_COORD" "$WIDTH" "$HEIGHT"
		rm -f /tmp/"$random_name"_first_page
		;;
	# video/*)
	# 	remove_image
	# 	random_name="$(cksum "$FILE_PATH" | cut -d ' ' -f1)"
	# 	# Calculate the offset
	# 	meta_file="$(get_preview_meta_file "$FILE_PATH")"
	# 	y_offset="$(cat "$meta_file" | grep "y-offset" | awk '{print $2}')"
	# 	HEIGHT="$(( "$HEIGHT" - ("$y_offset") - 1 ))"
	# 	Y_COORD="$(( "$Y_COORD" + ("$y_offset") + 1 ))"

	# 	# Preview a thumbnail
	# 	# We execute the command in a subshell to prevent errors from breaking the TUI
	# 	( (ffmpegthumbnailer -i "$FILE_PATH" -f -m -c jpg -s 512 -q 6 -o /tmp/"$random_name"_video) )
	# 	show_image /tmp/"$random_name"_video "$X_COORD" "$Y_COORD" "$WIDTH" "$HEIGHT"
	# 	rm -f /tmp/"$random_name"_video
	# 	;;
	*)
		remove_image
		;;
esac
