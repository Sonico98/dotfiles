#!/bin/bash

# wm-theme [night|day]
# Sets dark mode on or off, by Sonico
# In need of a full rewrite

if [[ "$XDG_CURRENT_DESKTOP" =~ (KDE|GNOME|XFCE4|Unity|Pantheon|Elementary|LXDE) ]]; then
	echo "Not running a WM"
	exit 1
fi

# Quick fix
if [ "$1" != "night" ]; then
	if [ "$1" != "day" ]; then
		echo "Not a valid theme"
		exit 1
	fi
fi

# Theme names ########################
# light_gtk_theme="Orchis-Red-Light"
# dark_gtk_theme="Orchis-Red-Dark"
light_gtk_theme="Fluent-round-red-Light"
dark_gtk_theme="Fluent-round-red-Dark"
light_gtk_icon="Fluent-red"
dark_gtk_icon="Fluent-red-dark"
kitty_light="Material Light"
kitty_dark="Material Dark"
wine_light="wine-reset-theme.reg"
wine_dark="wine-breeze-dark.reg"
vim_light="light"
vim_dark="dark"
airline_light="ayu"
airline_dark="wombat"
btop_light="flat-remix-light.theme"
btop_dark="monokai.theme"

# Hex colors #########################
# Background #########################
dunst_bg_light="#FFFFFFCC"
dunst_bg_dark="#00000085"
dolphin_bg_dark="40,40,40"
dolphin_bg_light="255,255,255"
dolphin_css_dark="#282828"
dolphin_css_light="#FFFFFF"
i3_border_light="#e31d11"
i3_border_dark="#f28b82"
rofi_bg_light="#FFFFFF45"
rofi_bg_dark="#00000045"
# Foreground #########################
rofi_fg_light="#000000FF"
rofi_fg_dark="#EFEFEF"
dunst_fg_light="#212121"
dunst_fg_dark="#C8C8C8"

# Configuration paths ################
rofi_conf_path="$HOME/.config/rofi"
plb_conf_path="$HOME/.config/polybar"
wine_conf_path="$HOME/.config/wine"


# Script start
echo "Changing theme, please wait..."
case "$1" in
    day)
        # Light mode
	kitty_theme="$kitty_light"
	new_airline="$airline_light"
	prev_airline="$airline_dark"
	new_btop="$btop_light"
	prev_btop="$btop_dark"
	new_dolphin_bg="$dolphin_bg_light"
	prev_dolphin_bg="$dolphin_bg_dark"
	new_dolphin_css="$dolphin_css_light"
	prev_dolphin_css="$dolphin_css_dark"
	new_dunst_bg="$dunst_bg_light"
	new_dunst_fg="$dunst_fg_light"
	prev_dunst_bg="$dunst_bg_dark"
	prev_dunst_fg="$dunst_fg_dark"
	new_gtk_theme="$light_gtk_theme"
	prev_gtk_theme="$dark_gtk_theme"
	new_gtk_icon="$light_gtk_icon"
	prev_i3_border="$i3_border_dark"
	new_i3_border="$i3_border_light"
	new_plb_theme='${colors-light'
	prev_plb_theme='${colors-dark'
	new_rofi_bg="$rofi_bg_light"
	new_rofi_fg="$rofi_fg_light"
	prev_rofi_bg="$rofi_bg_dark"
	prev_rofi_fg="$rofi_fg_dark"
	new_vim="$vim_light"
	prev_vim="$vim_dark"
	wine_theme="$wine_light"

	# Change the wallpaper
	 # pkill -9 -f i3-dynamic-backgrounds
	 # python $HOME/.bins/i3-dynamic-backgrounds/main.py -t 2 \
	 # 	$HOME/Pictures/.wallpapers/Light &> /dev/null &
	;;
    night)
	# Dark mode
	kitty_theme="$kitty_dark"
	new_airline="$airline_dark"
	prev_airline="$airline_light"
	new_btop="$btop_dark"
	prev_btop="$btop_light"
	new_dolphin_bg="$dolphin_bg_dark"
	prev_dolphin_bg="$dolphin_bg_light"
	new_dolphin_css="$dolphin_css_dark"
	prev_dolphin_css="$dolphin_css_light"
	new_dunst_bg="$dunst_bg_dark"
	new_dunst_fg="$dunst_fg_dark"
	prev_dunst_bg="$dunst_bg_light"
	prev_dunst_fg="$dunst_fg_light"
	new_gtk_theme="$dark_gtk_theme"
	prev_gtk_theme="$light_gtk_theme"
	new_gtk_icon="$dark_gtk_icon"
	prev_i3_border="$i3_border_light"
	new_i3_border="$i3_border_dark"
	new_plb_theme='${colors-dark'
	prev_plb_theme='${colors-light'
	new_rofi_bg="$rofi_bg_dark"
	new_rofi_fg="$rofi_fg_dark"
	prev_rofi_bg="$rofi_bg_light"
	prev_rofi_fg="$rofi_fg_light"
	new_vim="$vim_dark"
	prev_vim="$vim_light"
	wine_theme="$wine_dark"

	# Change the wallpaper
	 # pkill -9 -f i3-dynamic-backgrounds
	 # python $HOME/.bins/i3-dynamic-backgrounds/main.py -t 2 \
	 # 	$HOME/Pictures/.wallpapers/Dark &> /dev/null &
	;;
esac

# Change polybar's colors. Also kill the program that hides the MPRIS module.
sed -i "s/$prev_plb_theme/$new_plb_theme/" "$plb_conf_path"/config
sed -i "s/$prev_plb_theme/$new_plb_theme/" "$plb_conf_path"/config_systray
"$HOME"/.dotfiles/scripts/polybar/relaunch_polybar.sh b &> /dev/null

# Change kitty terminal's colors
kitty +kitten themes --reload-in=all "$kitty_theme"

# Change i3 border color
sed -i "s/$prev_i3_border/$new_i3_border/g" "$HOME/.config/i3/config" &> /dev/null
i3-msg reload &> /dev/null

# Change GTK and QT themes
sed -i "s#$prev_dolphin_bg#$new_dolphin_bg#" "$HOME/.config/kdeglobals"
sed -i "s/$prev_dolphin_css/$new_dolphin_css/" "$HOME/.config/qt5ct/qss/dolphin.qss"
sed -i "s#Net/ThemeName .*#Net/ThemeName \"$new_gtk_theme\"#" $HOME/.xsettingsd
sed -i "s#Net/IconThemeName .*#Net/IconThemeName \"$new_gtk_icon\"#" $HOME/.xsettingsd 
sed -i "s#gtk-theme-name=.*#gtk-theme-name=\"$new_gtk_theme\"#" "$HOME/.config/gtk-3.0/settings.ini"
sed -i "s#gtk-icon-theme-name=.*#gtk-icon-theme-name=\"$new_gtk_icon\"#" "$HOME/.config/gtk-3.0/settings.ini"
sed -i "s#gtk-theme-name=.*#gtk-theme-name=\"$new_gtk_theme\"#" "$HOME/.gtkrc-2.0"
sed -i "s#gtk-icon-theme-name=.*#gtk-icon-theme-name=\"$new_gtk_icon\"#" "$HOME/.gtkrc-2.0"
sed -i "s#icon_theme=.*#icon_theme=$new_gtk_icon#" $HOME/.config/qt5ct/qt5ct.conf
sed -i "s#icon_theme=.*#icon_theme=$new_gtk_icon#" $HOME/.config/qt6ct/qt6ct.conf


## Apply the change using xsettingsd
killall -HUP xsettingsd


# Change rofi's colors
sed -i "s/    background-color: $prev_rofi_bg/    background-color: $new_rofi_bg/" "$rofi_conf_path"/config.rasi
sed -i "s/    text-color: $prev_rofi_fg/    text-color: $new_rofi_fg/" "$rofi_conf_path"/config.rasi


# Change dunst's colors
sed -i "s/$prev_dunst_bg/$new_dunst_bg/" $HOME/.config/dunst/dunstrc
sed -i "s/$prev_dunst_fg/$new_dunst_fg/" $HOME/.config/dunst/dunstrc
systemctl --user restart dunst.service &> /dev/null &


# Change wine's colors. Restarting existing wine applications is necessary
(wine regedit "$wine_conf_path/$wine_theme" &> /dev/null) &


# Change NVIM's theme. Only works if using vimscript as config file
if [ -f "$HOME/.config/nvim/init.vim" ]; then
	sed -i "s/let ayucolor='$prev_vim'/let ayucolor='$new_vim'/" $HOME/.config/nvim/init.vim
	sed -i "s/set background=$prev_vim/set background=$new_vim/" $HOME/.config/nvim/init.vim
	sed -i "s/let g:airline_theme='$prev_airline'/let g:airline_theme='$new_airline'/" $HOME/.config/nvim/init.vim
	# Since nvim doesn't yet support the --serverlist option (as of version 0.8.0),
	# we assume the servers are stored under /run/user/1000. Should work for vim as well
	for nvim_server in /run/user/1000/nvim*; do
		nvim --server "$nvim_server" --remote-send ':source $MYVIMRC<CR>' &> /dev/null &
	done
fi


# Change Btop's theme
sed -i "s/$prev_btop/$new_btop/" $HOME/.config/btop/btop.conf


# Send a little notification
sleep 1		# So the daemon, dunstd, has time to start
notify-send "Clight" "We're now during the '$1'!"


echo "Done!"
exit 0
