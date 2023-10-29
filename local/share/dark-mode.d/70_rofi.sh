#!/bin/bash

rofi_conf_path="$HOME/.config/rofi/config.rasi"
rofi_dark_bg="#00000045"
rofi_dark_fg="#EFEFEF"
rofi_light_bg="#FFFFFF45"
rofi_light_fg="#000000FF"

sed -i -e "s/    background-color: $rofi_light_bg/    background-color: $rofi_dark_bg/" \
	-e "s/    text-color: $rofi_light_fg/    text-color: $rofi_dark_fg/" \
	"$rofi_conf_path"
