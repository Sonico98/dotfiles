#!/bin/bash

gnomeschema="org.gnome.desktop.interface"

gsettings set "$gnomeschema" color-scheme 'prefer-dark'
gsettings set "$gnomeschema" gtk-theme 'Fluent-round-red-Dark'
gsettings set "$gnomeschema" icon-theme 'Fluent-red-dark'
gsettings set "$gnomeschema" cursor-theme 'posy-black-tiny'
gsettings set "$gnomeschema" font-name 'GoogleSans Nerd Font, 14'
notify-send "Dark mode"
