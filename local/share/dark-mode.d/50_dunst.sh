#!/bin/bash

dunst_conf_path="$HOME/.config/dunst/dunstrc"
dark_dunst_bg="#00000085"
dark_dunst_fg="#C8C8C8"
light_dunst_bg="#FFFFFFCC"
light_dunst_fg="#212121"

sed -i -e "s/$light_dunst_bg/$dark_dunst_bg/" \
	-e "s/$light_dunst_fg/$dark_dunst_fg/" \
	"$dunst_conf_path"

systemctl --user restart dunst.service
