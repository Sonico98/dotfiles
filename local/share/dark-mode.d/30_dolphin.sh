#!/bin/bash

dolphin_bg_light="255,255,255"
dolphin_bg_dark="40,40,40"
dolphin_css_light="#FFFFFF"
dolphin_css_dark="#282828"

sed -i "s#$dolphin_bg_light#$dolphin_bg_dark#" "$HOME/.config/kdeglobals"
sed -i "s/$dolphin_css_light/$dolphin_css_dark/" "$HOME/.config/qt5ct/qss/dolphin.qss"
