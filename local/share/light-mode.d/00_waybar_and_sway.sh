#!/bin/bash

sway_conf_path="$HOME/.config/sway/config"
wallpaper="/home/sonico/Pictures/Anime/The iDOLM@STER/[0] Million Live/Theater Days/Desktop Wallpapers/Momoko Suou/1698748827519575.jpg"
dark_sway_border="#f28b82"
light_sway_border="#fec045"

# Waybar
rm -f ~/.config/waybar/style.css
ln -s ~/.config/waybar/{style_light.css,style.css}
# Wallpaper
rm -f ~/.bg
ln -s "$wallpaper" ~/.bg
# Sway border color
sed -i "s/$dark_sway_border/$light_sway_border/g" "$sway_conf_path"
swaymsg reload
