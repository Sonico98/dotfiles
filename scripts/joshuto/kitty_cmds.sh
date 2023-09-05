#!/bin/zsh
# Programs required: kitty, fd, p7zip, timg
# openArchives script: https://www.github.com/Sonico98/7zip-Extract

files=("${@:2}")
if [ "${#files[@]}" -ne 0 ]; then
	args=()
	for file in "${files[@]}"; do
		path_and_file="$(echo "$(pwd)"/"$file")"
		args+=("$path_and_file")
	done
fi


id=""
while getopts ":DPdesut:" option; do
	case $option in
		# Preview all images in a directory with timg, in natural order (sort -V)
		D)
			# Explanation of each line after sh -c:
			# 1. Check for the existence of image files in the current directory
			# 2. Get all image files in the current directory
			# 3. Sort the list in natural order 
			# (OPTIONAL: and get their thumbnails)
			# (add "xargs -I {} allmytoes -sx {} |" before awk)
			# (The downside is that the filenames will be wrong, but processing faster)
			# 4. Enclose each entry in quotes
			# 5. Pass the images to timg using xargs
			# 6. Ask for user input
			tbid="$(kitty @ launch --type=tab --title='Folder images preview' \
				--cwd=current --location hsplit sh -c \
				'if ls ./*.jpg &>/dev/null || ls ./*.jpeg &>/dev/null || \
				ls ./*.JPG &>/dev/null || ls ./*.png &>/dev/null || \
				ls ./*.PNG &>/dev/null || ls ./*.gif &>/dev/null || \
				ls ./*.GIF &>/dev/null || ls ./*.webp &>/dev/null || \
				ls ./*.WEBP &>/dev/null; then
				fd -e jpg -e jpeg -e JPG -e png -e PNG -e gif -e GIF -e webp -e WEBP -d 1 | \
				sort -V | awk -v q=\" '\''{ print q $0 q }'\'' | \
				xargs timg --compress=5 --grid=4x4 -U -C -I \
				-bnone -pk --frames=1 --threads=4 --title=%f; \
				else echo "No image files found"; fi;
				read -s -p '"'Press ENTER to continue'"'')"
			;;
		# Preview PDFs
		P)
			tbid="$(kitty @ launch --type=tab --title='PDF preview' \
				--cwd=current termpdf.py "${args[@]}")"
		;;
		# Extract files
		e)
			id="$(kitty @ launch --title='Extract files' \
				--cwd=current --location split openArchives.sh -e "${args[@]}")"
			;;
		# Archive files
		d) # split into 2GB files
			id="$(kitty @ launch --title='Archive files - 2GB Files' \
				--cwd=current --location split archiveFiles.sh -d "${args[@]}")"
			;;
		s) # store
			id="$(kitty @ launch --title='Archive files - Store' \
				--cwd=current --location split archiveFiles.sh -s "${args[@]}")"
			;;
		u) # ultra compression
			id="$(kitty @ launch --title='Archive files - Ultra Compression' \
				--cwd=current --location split archiveFiles.sh -u "${args[@]}")"
			;;
		t) # Open sub-shell
			kitten run-shell kitty @ set-tab-title "Joshuto terminal" \
				&& kitty @ set-tab-title "Joshuto"
			;;
		\?)
			echo "Wrong parameter"
			exit 1
			;;
	esac
done

{
if [ "$id" != "" ]; then
	kitty @ resize-window -m id:"$id" -a vertical -i -100
	kitty @ resize-window -m id:"$id" -a vertical -i 5
fi
} &> /dev/null

