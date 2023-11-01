#!/bin/bash

gtk_icon_name="Fluent-orange-light"
qt_color_scheme="Custom Orange Light"

# QT 5
sed -i -e "s#icon_theme=.*#icon_theme=$gtk_icon_name#" \
	-e "s#color_scheme_path=.*#color_scheme_path=/home/sonico/.config/qt5ct/colors/$qt_color_scheme.conf#" \
	"$HOME"/.config/qt5ct/qt5ct.conf
# QT 6
sed -i -e "s#icon_theme=.*#icon_theme=$gtk_icon_name#" \
	-e "s#color_scheme_path=.*#color_scheme_path=/home/sonico/.config/qt5ct/colors/$qt_color_scheme.conf#" \
	"$HOME"/.config/qt6ct/qt6ct.conf

