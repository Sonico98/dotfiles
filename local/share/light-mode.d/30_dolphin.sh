#!/bin/bash

dolphin_bg_light="255,255,255"
dolphin_bg_dark="40,40,40"
dolphin_css_light="#FFFFFF"
dolphin_css_dark="#282828"

sed -i "s#$dolphin_bg_dark#$dolphin_bg_light#" "$HOME/.config/kdeglobals"
sed -i "s/$dolphin_css_dark/$dolphin_css_light/" "$HOME/.config/qt5ct/qss/dolphin.qss"
