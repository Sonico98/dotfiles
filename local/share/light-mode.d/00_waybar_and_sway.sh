#!/bin/bash

source "$HOME"/.local/share/darkman-common.d/functions.sh
source "$HOME"/.local/share/darkman-common.d/theme_names.sh
source "$HOME"/.local/share/darkman-common.d/wallpaper.sh

wallpaper="$light_wallpaper"
style_to_set="$light_waybar_theme"

set_waybar_theme
set_sway_theme "light"
# Apply the changes
export SWAYSOCK=/run/user/$(id -u)/sway-ipc.$(id -u).$(pgrep -x sway).sock && swaymsg reload
set_wallpaper
