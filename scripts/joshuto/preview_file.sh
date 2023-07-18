#!/usr/bin/env sh
# Joshuto will call this script for each file when first hovered by the cursor.
# If this script returns with an exit code 0, the stdout of this script will be 
# the file's preview text in Joshuto's right panel.
# The preview text will be cached by Joshuto and only renewed on reload.
# ANSI color codes are supported if Joshuto is build with the `syntax_highlight`
# feature.


# Meanings of exit codes:
# code | meaning    | action of ranger
# -----+------------+-------------------------------------------
# 0    | success    | success. display stdout as preview
# 1    | no preview | failure. display no preview at all


# This script is used only as a provider for textual previews.
# Image previews are independent from this script.

IFS=$'\n'

# Security measures:
# * noclobber prevents you from overwriting a file with `>`
# * noglob prevents expansion of wild cards
# * nounset causes bash to fail if an undeclared variable is used (e.g. typos)
# * pipefail causes a pipeline to fail also if a command other than the last one fails
set -o noclobber -o noglob -o nounset -o pipefail


# Meaningful aliases for arguments:
path="$1"            # Full path of the selected file
width="$2"           # Width of the preview pane (number of fitting characters)
height="$3"          # Height of the preview pane (number of fitting characters)

while [ "$#" -gt 0 ]; do
	case "$1" in
		"--path")
			shift
			path="$1"
			;;
		"--preview-width")
			shift
			width="$1"
			;;
		"--preview-height")
			shift
			height="$1"
			;;
	esac
	shift
done


# Find out something about the file:
mimetype=$(file --mime-type -Lb "$path")
extension=$(/bin/echo "${path##*.}" | awk '{print tolower($0)}')


# Functions:
# runs a command and saves its output into $output.  Useful if you need
# the return value AND want to use the output in a pipe
try() { output=$(eval '"$@"'); }

# writes the output of the previously used "try" command
dump() { /bin/echo "$output"; }

# a common post-processing function used after most commands
maxln=200    # Stop after $maxln lines.
trim() { head -n "$maxln"; }

# wraps highlight to treat exit code 141 (killed by SIGPIPE) as success
safepipe() { "$@"; test $? = 0 -o $? = 141; }


tmsu_tag_list() {
	taglist="$(exiftool -q -q -Keywords "$path" | cut -d':' -f2 | xargs)"
    result=$?
    if [ $result -eq 0 ]; then
        if ! [ -z "$taglist" ]; then
            echo "Tags: $taglist" | fold -s -w "$1"
        fi
    fi
}


case "$extension" in
    # Archive extensions:
    7z|a|ace|alz|arc|arj|bz|bz2|cab|cpio|deb|gz|jar|lha|lz|lzh|lzma|lzo|\
    rar|rpm|rz|t7z|tar|tbz|tbz2|tgz|tlz|txz|tZ|tzo|war|xpi|xz|Z|zip)
		SevenZoutput="$(7z -ba -p l "$path" | \
			awk '{for(i=6;i<=NF;++i)printf $i""FS ; print ""}' | \
			cut -d'/' -f2-)"

        try echo "$SevenZoutput" && { dump | trim; exit 0; }
        exit 1;;
	# PDF documents:
    pdf)
		pages="Page count: $(exiftool -q -q -PageCount "$path" | awk '{print $4}')"
		echo "$pages"
		exit 0;;
    # HTML Pages:
    htm|html|xhtml)
        try w3m    -dump "$path" && { dump | trim | fmt -s -w $width; exit 4; }
        try lynx   -dump "$path" && { dump | trim | fmt -s -w $width; exit 4; }
        try elinks -dump "$path" && { dump | trim | fmt -s -w $width; exit 4; }
        ;;
	# Substation Alpha
	ass|ssa)
		# Cut the output to avoid performance degradation
		bat -pp --color always "$path" | head -1000; exit 0
		;;
esac


case "$mimetype" in
	audio/*)
		tags=$(exiftool -q -q -S -FileName -Title -SortName -Titlesort -Artist \
			-SortArtist -Artistsort -Album -SortAlbum -Albumsort \
			-TrackNumber \-Duration "$path" | \
			sed -e 's/FileName: //' -e 's/^Title: /\nTitle:\n/' \
			-e 's/^Titlesort: /\nSort Title:\n/' -e 's/SortName: /\nSort Title:\n/' \
			-e 's/^Artist: /\nArtist:\n/' -e 's/^Artistsort: /\nSort Artist:\n/' \
			-e 's/SortArtist: /\nSort Artist:\n/' -e 's/^Album: /\nAlbum:\n/' \
			-e 's/SortAlbum: /\nSort Album:\n/' -e 's/^Albumsort: /\nSort Album:\n/' \
			-e 's/TrackNumber: /\nTrack Number:\n/' \
			-e 's/Duration: /\nDuration:\n/' | fold -s -w "$width")
		echo "$tags"
		exit 0
		;;
    image/*)
		meta_file="$(get_preview_meta_file "$path")"
		dimension="Size: $(exiftool -q -q -ImageSize "$path" | awk '{print $4}')"
        tags=$(tmsu_tag_list "$width")
		header="$(echo "$dimension" && echo "$tags")"
		echo "$header"
		y_offset="$(( "$(echo "$header" | sed -n '=' | wc -l)" + 1))"
        echo "y-offset $y_offset" > "$meta_file"
        exit 0
        ;;
	text/* | */xml | */json)
        try safepipe bat -pp --color always "$path" && { dump | trim; exit 0; }
        try cat "$path" && { dump | trim; exit 0; }
        exit 1
		;;
    video/*)
		# Information to show if thumbnail previews were enabled
		# meta_file="$(get_preview_meta_file "$path")"
		# filename="$(basename "$path")"
		# dimension="Size: $(exiftool -ImageSize "$path" | awk '{print $4}')"
		# header="$(echo "$filename" && echo "$dimension")"
		# echo "$header"
		# y_offset="$(( "$(echo "$header" | wc -l)" ))"
        # echo "y-offset $y_offset" > "$meta_file"
        # exit 0
		exiftool --Directory --FileModifyDate --FileAccessDate --FileCreateDate \
			--FileInodeChangeDate --FilePermissions --FileTypeExtension --EBMLVersion \
			--EBMLReadVersion --DocType --DocTypeVersion --DocTypeReadVersion \
			--TimecodeScale --MuxingApp --WritingApp --DateTimeOriginal \
			--MegaPixels --CreateDate --Modifydate "$path" \
			| sed 's/File\sName                       : //' | tail -n+2 && { dump | trim; exit 0; }
		;;
esac

exit 1
