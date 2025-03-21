#!/bin/bash

source "$HOME"/.local/share/darkman-common.d/functions.sh
source "$HOME"/.local/share/darkman-common.d/theme_names.sh
source "$HOME"/.local/share/darkman-common.d/wallpaper.sh

wallpaper="$dark_wallpaper"
style_to_set="$dark_waybar_theme"

set_waybar_theme
set_sway_theme "dark"
set_wallpaper
