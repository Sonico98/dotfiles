#!/bin/bash
# Do not touch this file unless you know what you're doing!

source "$HOME"/.local/share/darkman-common.d/config_files.sh
source "$HOME"/.local/share/darkman-common.d/colors.sh
source "$HOME"/.local/share/darkman-common.d/theme_names.sh

set_waybar_theme() {
	rm -f "$waybar_style_path"/style.css
	ln -s "$waybar_style_path"/{"$style_to_set",style.css}
}

set_sway_theme() {
	case "$1" in
		"light")
			old_border="$dark_sway_border"
			new_border="$light_sway_border"
			;;
		"dark")
			old_border="$light_sway_border"
			new_border="$dark_sway_border"
			;;
	esac
	sed -i "s/$old_border/$new_border/g" "$sway_conf_path"
}

set_wallpaper() {
	rm -f ~/.bg
	ln -s "$wallpaper" ~/.bg
	swww img ~/.bg --transition-type random --transition-step 40 --transition-fps 60 --transition-angle 35
}

set_gtk_theme() {
	# GTK 2
	sed -i -e "s#gtk-theme-name=.*#gtk-theme-name=\"$gtk_theme\"#" \
		-e "s#gtk-icon-theme-name=.*#gtk-icon-theme-name=\"$gtk_icon\"#" \
		"$gtk2_conf_path"
	# GTK 3
	sed -i -e "s#gtk-theme-name=.*#gtk-theme-name=\"$gtk_theme\"#" \
		-e "s#gtk-icon-theme-name=.*#gtk-icon-theme-name=\"$gtk_icon\"#" \
		-e "s#gtk-application-prefer-dark-theme=.*#gtk-application-prefer-dark-theme="$bool"#" \
		"$gtk3_conf_path"
	# GTK 4
	sed -i -e "s#gtk-theme-name=.*#gtk-theme-name=\"$gtk_theme\"#" \
		-e "s#gtk-icon-theme-name=.*#gtk-icon-theme-name=\"$gtk_icon\"#" \
		-e "s#gtk-application-prefer-dark-theme=.*#gtk-application-prefer-dark-theme="$bool"#" \
		"$gtk4_conf_path"
}

set_qt_theme() {
	# QT 5
	sed -i -e "s#icon_theme=.*#icon_theme=$gtk_icon_name#" \
		-e "s#color_scheme_path=.*#color_scheme_path=$qt5_color_scheme_path/$qt_color_scheme.conf#" \
		"$qt5ct_conf_path"
	# QT 6
	sed -i -e "s#icon_theme=.*#icon_theme=$gtk_icon_name#" \
		-e "s#color_scheme_path=.*#color_scheme_path=$qt6_color_scheme_path/$qt_color_scheme.conf#" \
		"$qt6ct_conf_path"
}

set_dolphin_theme() {
	case "$1" in
		"light")
			old_bg="$dolphin_bg_dark"
			new_bg="$dolphin_bg_light"
			old_css="$dolphin_css_dark"
			new_css="$dolphin_css_light"
			;;
		"dark")
			old_bg="$dolphin_bg_light"
			new_bg="$dolphin_bg_dark"
			old_css="$dolphin_css_light"
			new_css="$dolphin_css_dark"
			;;
	esac
	sed -i "s#$old_bg#$new_bg#" "$kdeglobals_path"
	sed -i "s/$old_css/$new_css/" "$dolphin_qss_path"
}

set_nvim_theme() {
	case "$1" in
		"light")
			old="dark"
			new="light"
			;;
		"dark")
			old="light"
			new="dark"
			;;
	esac
	sed -i -e "s#vim.o.background = \"$old\"#vim.o.background = \"$new\"#" \
		-e "s#vim.g.ayucolor = \"$old\"#vim.g.ayucolor = \"$new\"#" \
		"$nvim_theme_path"
}

set_dunst_theme() {
	case "$1" in
		"light")
			old_bg="$dark_dunst_bg"
			new_bg="$light_dunst_bg"
			old_fg="$dark_dunst_fg"
			new_fg="$light_dunst_fg"
			;;
		"dark")
			old_bg="$light_dunst_bg"
			new_bg="$dark_dunst_bg"
			old_fg="$light_dunst_fg"
			new_fg="$dark_dunst_fg"
			;;
	esac

	sed -i -e "s/$old_bg/$new_bg/" \
		-e "s/$old_fg/$new_fg/" \
		"$dunst_conf_path"
	systemctl --user restart dunst.service
}

set_kitty_theme() {
	kitty +kitten themes --reload-in=all "$kitty_theme"
}

set_rofi_theme() {
	case "$1" in
		"light")
			old_theme="$rofi_dark_theme"
			new_theme="$rofi_light_theme"
			;;
		"dark")
			old_theme="$rofi_light_theme"
			new_theme="$rofi_dark_theme"
			;;
	esac

	sed -i -e \
		"s/theme \"$old_theme\"/theme \"$new_theme\"/" \
		"$rofi_conf_path/config.rasi" "$rofi_conf_path/config_list.rasi"
}

set_yazi_theme() {
	case "$1" in
		"light")
			new_theme="$yazi_conf_path/themes/$yazi_light_theme/theme.toml"
			;;
		"dark")
			new_theme="$yazi_conf_path/themes/$yazi_dark_theme/theme.toml"
			;;
	esac

	rm -f "$yazi_conf_path"/theme.toml
	ln -s "$new_theme" "$yazi_conf_path"/theme.toml
}

set_btop_theme() {
	case "$1" in
		"light")
			old="$btop_dark_theme"
			new="$btop_light_theme"
			;;
		"dark")
			old="$btop_light_theme"
			new="$btop_dark_theme"
			;;
	esac

	sed -i "s/$old/$new/" "$btop_conf_path"
}

set_gsts_theme() {
	gsettings set "$gnomeschema" gtk-theme "$gtk_theme"
	gsettings set "$gnomeschema" icon-theme "$gtk_icon"
	gsettings set "$gnomeschema" cursor-theme "$cursor_theme"
	gsettings set "$gnomeschema" font-name "$font_name"
}
