#!/bin/bash
# Do not touch this file unless you know what you're doing!

source "$HOME"/.local/share/darkman-common.d/config_files.sh
source "$HOME"/.local/share/darkman-common.d/colors.sh
source "$HOME"/.local/share/darkman-common.d/theme_names.sh

set_waybar_theme() {
	rm -f "$waybar_style_dir"/style.css
	ln -s "$waybar_style_dir"/{"$style_to_set",style.css}
	killall -SIGUSR2 waybar &
}

set_sway_theme() {
	SWAYSOCK=/run/user/$(id -u)/sway-ipc.$(id -u).$(pgrep -x sway).sock
	case "$1" in
		"light")
			old_border="$dark_sway_border"
			old_border_inactive="$dark_sway_border_inactive"
			old_shadow="$dark_sway_shadow"
			new_border="$light_sway_border"
			new_border_inactive="$light_sway_border_inactive"
			new_shadow="$light_sway_shadow"
			;;
		"dark")
			old_border="$light_sway_border"
			old_border_inactive="$light_sway_border_inactive"
			old_shadow="$light_sway_shadow"
			new_border="$dark_sway_border"
			new_border_inactive="$dark_sway_border_inactive"
			new_shadow="$dark_sway_shadow"
			;;
	esac
	sed -i "s/$old_border/$new_border/g" "$sway_conf_dir/appearance"
	sed -i "s/$old_border_inactive/$new_border_inactive/g" "$sway_conf_dir/appearance"
	sed -i "s/shadow_color \"$old_shadow\"/shadow_color \"$new_shadow\"/" "$sway_conf_dir/appearance_fx"
	export SWAYSOCK && swaymsg seat seat0 xcursor_theme "Bibata-Rainbow-Modern"
	export SWAYSOCK && swaymsg shadow_color "$new_shadow"
	active="$(grep -m 1 "client.focused" $sway_conf_dir/appearance | tr -s " " | tr -d "	")"
	inactive="$(grep -m 1 "client.focused_inactive" $sway_conf_dir/appearance | tr -s " " | tr -d "	")"
	border_a="$(echo "$active" | cut -d ' ' -f2)"
	backgr_a="$(echo "$active" | cut -d ' ' -f3)"
	text_a="$(echo "$active" | cut -d ' ' -f4)"
	indicator_a="$(echo "$active" | cut -d ' ' -f5)"
	childb_a="$(echo "$active" | cut -d ' ' -f6)"
	export SWAYSOCK && swaymsg client.focused "$border_a" "$backgr_a" "$text_a" "$indicator_a" "$childb_a" &
	border_i="$(echo "$inactive" | cut -d ' ' -f2)"
	backgr_i="$(echo "$inactive" | cut -d ' ' -f3)"
	text_i="$(echo "$inactive" | cut -d ' ' -f4)"
	indicator_i="$(echo "$inactive" | cut -d ' ' -f5)"
	childb_i="$(echo "$inactive" | cut -d ' ' -f6)"
	export SWAYSOCK && swaymsg client.focused_inactive "$border_i" "$backgr_i" "$text_i" "$indicator_i" "$childb_i" &
}

set_wallpaper() {
	rm -f ~/.bg
	ln -s "$wallpaper" ~/.bg
	swww img ~/.bg --transition-type random --transition-step 75 --transition-fps 25 --transition-angle 35 &
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
		-e "s#color_scheme_path=.*#color_scheme_path=$qt5_color_scheme_dir/$qt_color_scheme.conf#" \
		"$qt5ct_conf_path"
	# QT 6
	sed -i -e "s#icon_theme=.*#icon_theme=$gtk_icon_name#" \
		-e "s#color_scheme_path=.*#color_scheme_path=$qt6_color_scheme_dir/$qt_color_scheme.conf#" \
		"$qt6ct_conf_path"
}

set_kde_theme() {
	case "$1" in
		"light")
			plasma_theme="$light_kde_theme"
			old_accent="$dark_accent_color"
			new_accent="$light_accent_color"
			;;
		"dark")
			plasma_theme="$dark_kde_theme"
			old_accent="$light_accent_color"
			new_accent="$dark_accent_color"
			;;
	esac
	sed -i -e "s#AccentColor=$old_accent#AccentColor=$new_accent#" "$kdeglobals_path"
	lookandfeeltool -platform offscreen -a "$plasma_theme"
	kwriteconfig6 --file ~/.config/kdeglobals --group Icons --key Theme "$dark_gtk_icon"
	kwriteconfig6 --file ~/.config/kcminputrc --group Mouse --key cursorTheme "$cursor_theme"
	kwriteconfig6 --file ~/.config/gtk-3.0/settings.ini --group Settings --key gtk-cursor-theme-name "$cursor_theme"
	kwriteconfig6 --file ~/.config/gtk-4.0/settings.ini --group Settings --key gtk-cursor-theme-name "$cursor_theme"
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
	kitty +kitten themes --reload-in=all "$kitty_theme" &
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
		"$rofi_conf_dir/config.rasi" "$rofi_conf_dir/config_list.rasi"
}

set_yazi_theme() {
	case "$1" in
		"light")
			new_theme="$yazi_conf_dir/themes/$yazi_light_theme/theme.toml"
			;;
		"dark")
			new_theme="$yazi_conf_dir/themes/$yazi_dark_theme/theme.toml"
			;;
	esac

	rm -f "$yazi_conf_dir"/theme.toml
	ln -s "$new_theme" "$yazi_conf_dir"/theme.toml
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
