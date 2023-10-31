#!/bin/bash

light_gtk_theme="Fluent-round-red-Light"
light_gtk_icon="Fluent-red-light"

# GTK 2
sed -i -e "s#gtk-theme-name=.*#gtk-theme-name=\"$light_gtk_theme\"#" \
	-e "s#gtk-icon-theme-name=.*#gtk-icon-theme-name=\"$light_gtk_icon\"#" \
	"$HOME/.gtkrc-2.0"
# GTK 3
sed -i -e "s#gtk-theme-name=.*#gtk-theme-name=\"$light_gtk_theme\"#" \
	-e "s#gtk-icon-theme-name=.*#gtk-icon-theme-name=\"$light_gtk_icon\"#" \
	-e "s#gtk-application-prefer-dark-theme=.*#gtk-application-prefer-dark-theme=false#" \
	"$HOME/.config/gtk-3.0/settings.ini"
# GTK 4
sed -i -e "s#gtk-theme-name=.*#gtk-theme-name=\"$light_gtk_theme\"#" \
	-e "s#gtk-icon-theme-name=.*#gtk-icon-theme-name=\"$light_gtk_icon\"#" \
	-e "s#gtk-application-prefer-dark-theme=.*#gtk-application-prefer-dark-theme=false#" \
	"$HOME/.config/gtk-4.0/settings.ini"

