#!/bin/bash

sway_conf_path="$HOME/.config/sway/config"
wallpaper="/mnt/Heaven/Pictures/Anime/Date a Live/Kurumi Tokisaki/fa61dc2ef271065fd17c887644e04326.jpg" 
dark_sway_border="#f28b82"
light_sway_border="#e31d11"

# Waybar
rm -f ~/.config/waybar/style.css
ln -s ~/.config/waybar/{style_dark.css,style.css}
# Wallpaper
rm -f ~/.bg
ln -s "$wallpaper" ~/.bg
# Sway border color
sed -i "s/$light_sway_border/$dark_sway_border/g" "$sway_conf_path"
swaymsg reload
