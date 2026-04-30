#!/bin/bash

# Syntax:
# - A different wallpaper per output: OUTPUT·WALLPAPER¤OUTPUT·WALLPAPER
# - The same wallpaper across all outputs: <WALLPAPER>
#
# You can get output names executing `swaymsg -t get_outputs` or `wlr-randr`

# Light Wallpaper
LVDS="/home/sonico/Pictures/Wallpapers/(Pixiv) [Hiroko] 栞 - 128509050_p0.jpg"
VGA="/home/sonico/Pictures/Wallpapers/(Pixiv) [niyemiiii] 无题 - 104627556_p0_modified.jpg"
# LVDS="/usr/share/backgrounds/sway/Sway_Wallpaper_Blue_1920x1080.png"
light_wallpaper="VGA-1·$VGA¤LVDS-1·$LVDS"

# Dark Wallpaper
LVDS="/home/sonico/Pictures/Wallpapers/(Pixiv) [海奏hzh] 狼嵜光 - 127970978_p0.png"
VGA="/home/sonico/Pictures/Wallpapers/(Pixiv) [れるて] 初風 - 136209794_p0.jpg"
# LVDS="/usr/share/backgrounds/sway/Sway_Wallpaper_Blue_1920x1080.png"
dark_wallpaper="VGA-1·$VGA¤LVDS-1·$LVDS"
