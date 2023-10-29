#!/bin/bash

gnomeschema="org.gnome.desktop.interface"

gsettings set "$gnomeschema" color-scheme 'prefer-light'
gsettings set "$gnomeschema" gtk-theme 'Fluent-round-red-Light'
gsettings set "$gnomeschema" icon-theme 'Fluent-red-light'
gsettings set "$gnomeschema" cursor-theme 'posy-black-tiny'
gsettings set "$gnomeschema" font-name 'GoogleSans Nerd Font, 14'
notify-send "Light mode"
