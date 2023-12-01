#!/bin/bash

source "$HOME"/.local/share/darkman-common.d/functions.sh
source "$HOME"/.local/share/darkman-common.d/theme_names.sh
source "$HOME"/.local/share/darkman-common.d/wallpaper.sh

wallpaper="$dark_wallpaper"
style_to_set="$dark_waybar_theme"

set_waybar_theme
set_sway_theme "dark"
# Apply the changes
export SWAYSOCK=/run/user/$(id -u)/sway-ipc.$(id -u).$(pgrep -x sway).sock && swaymsg reload
set_wallpaper
