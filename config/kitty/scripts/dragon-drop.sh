#!/bin/bash

# The maximum amount of results to show on dragon-drop
# If this amount is exceded, a new terminal listing all found
# files gets opened
MAX_RESULTS=6

if [ -e "$1" ]; then
	dragon-drop --and-exit "$1"
else
	if [ -e "$(pwd)"/"$1" ]; then
		dragon-drop --and-exit "$(pwd)"/"$1"
	else
		# Try to find the file from a partial string
		search="$(fd "$1" "$(pwd)" -d 1)"
		tot_results="$(echo "$search" | sed '/^\s*$/d' | wc -l)"
		if [ "$tot_results" -gt "$MAX_RESULTS" ]; then
			notify-send '⚠️  Window Launched' 'Check the matches found for your selection'
			kitty --hold --title="Files matching selection" \
				echo -e "Too many files found:\n$search"
		else
			if [ "$tot_results" -gt 0 ]; then
				(echo "$search" | sort -V  | awk '{ print "\""$0"\""}' | \
					tr '\n' ' ' | xargs dragon-drop --and-exit)
			else
				notify-send '❌ Error' 'Not a file or directory'
			fi
		fi
	fi
fi
