#!/bin/zsh

set_cover_as_folder_picture_kde()
{
	if [ -f "$(pwd)"/Cover.jpg ]; then
		echo "[Desktop Entry]
Icon=./Cover.jpg

[Dolphin]
HeaderColumnWidths=589,162,189
PreviewsShown=true
Timestamp=2022,9,21,1,14,31.477
Version=4

[Settings]
HiddenFilesShown=false" >| "$(pwd)/$(echo ${PWD##*/})"/.directory
elif [ -f "$(pwd)"/Cover.png ]; then
	echo "[Desktop Entry]
Icon=./Cover.png

[Dolphin]
HeaderColumnWidths=589,162,189
PreviewsShown=true
Timestamp=2022,9,21,1,14,31.477
Version=4

[Settings]
HiddenFilesShown=false" >| "$(pwd)/$(echo ${PWD##*/})"/.directory
	fi
}

cd "$1"
mkdir "$(pwd)/$(echo ${PWD##*/})" && mv *.m4a "$(pwd)/$(echo ${PWD##*/})" && cp "$(pwd)"/Cover.(jpg|png) "$(pwd)/$(echo ${PWD##*/})"
set_cover_as_folder_picture_kde

exit $?
