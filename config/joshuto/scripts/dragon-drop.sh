#!/usr/bin/bash

while getopts ":e:t" option; do
	case $option in
		e)
			# The maximum amount of results to show with preview
			# If this exact amount of files or more is selected, --all-compact is used
			MAX_RESULTS=0
			if [ $# -gt "$MAX_RESULTS" ]; then
				dragon-drop --and-exit --all-compact "${@:2}"
			else
				dragon-drop --and-exit --all "${@:2}"
			fi
			;;
		t)
			source="$(dragon-drop --and-exit --target)"
			case "$source" in
				file*)
					file="$(echo "$source" | perl -MURI -MURI::Escape -lne \
						'print uri_unescape(URI->new($_)->path)')"
					if [ -f "$file" ];then
						cp "$file" "$(pwd)/"
					else
						notify-send "❌" "There was a problem getting the file"
					fi
					;;
				https*)
					wget -q "$source"
					dl_status=$?
					if [ "$dl_status" -eq 0 ]; then
						notify-send "✅" "File downloaded successfully"
					else
						notify-send "❌" "There was a problem getting the file"
					fi
					;;
				\?)
					notify-send "❌" "Whatever you dragged to the window is not supported"
					;;
			esac
			;;
		\?)
			notify-send "❌" "Invalid option"
			;;
		:)
			notify-send "❌" "Option -$OPTARG requires an argument"
			;;
	esac
done
