#!/bin/bash

source "$HOME"/.local/share/darkman-common.d/theme_names.sh
source "$HOME"/.local/share/darkman-common.d/functions.sh

gtk_theme="$dark_gtk_theme"
gtk_icon="$dark_gtk_icon"
gsettings set "$gnomeschema" color-scheme 'prefer-dark'
set_gsts_theme
