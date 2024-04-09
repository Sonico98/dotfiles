#!/bin/bash

for dir in */; do
	if [ -d "$dir" ]; then
		cd "$dir"
		for file in *.sh; do
			chmod +x "$file"
			sudo ln -s "$(pwd)"/"$file" /usr/local/bin/"${file%.*}"
		done
		cd ..
	fi
done
