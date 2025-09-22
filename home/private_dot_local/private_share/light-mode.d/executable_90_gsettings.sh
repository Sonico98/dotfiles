#!/bin/bash

source "$HOME"/.local/share/darkman-common.d/theme_names.sh
source "$HOME"/.local/share/darkman-common.d/functions.sh

gtk_theme="$light_gtk_theme"
gtk_icon="$light_gtk_icon"
gsettings set "$gnomeschema" color-scheme 'prefer-light'
set_gsts_theme
