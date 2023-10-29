#!/bin/bash

btop_conf_path="$HOME/.config/btop/btop.conf"
btop_dark_theme="monokai.theme"
btop_light_theme="flat-remix-light.theme"

sed -i "s/$btop_dark_theme/$btop_light_theme/" "$btop_conf_path"
