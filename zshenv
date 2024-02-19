# Set ZSH config directory
export ZDOTDIR=${HOME}/.config/zsh

# Set default programs
export EDITOR=nvim
export VISUAL=nvim
export PAGER=less
export SHELL=/bin/zsh
export TERMINAL=kitty

# Set default paths
export XDG_DATA_HOME=${HOME}/.local/share
export XDG_CONFIG_HOME=${HOME}/.config
export GEM_HOME=${HOME}/.local/share/gem/ruby/2.7.0
export GEM_2_BIN=${GEM_HOME}/bin
export GEM_HOME=${GEM_HOME}:${HOME}/.local/share/gem/ruby/3.0.0
export PATH=${PATH}:${GEM_2_BIN}
export PATH=${PATH}:${GEM_HOME}/bin
export PATH=${PATH}:${HOME}/.gem/ruby/3.0.0/bin
export PATH=${PATH}:${HOME}/.cargo/bin
export PATH=${PATH}:${HOME}/.npm-global/bin
export PATH=${PATH}:${HOME}/.local/bin
export PATH=${PATH}:${HOME}/.dotnet/tools
export GOPATH=${HOME}/.local/share/go
# Use the new crocus driver for Intel GPUs
export MESA_LOADER_DRIVER_OVERRIDE=crocus
# Disable dotnet Telemetry
export DOTNET_CLI_TELEMETRY_OPTOUT=1
# Devkitpro
export DEVKITPRO=/opt/devkitpro
export DEVKITARM=/opt/devkitpro/devkitARM
export DEVKITPPC=/opt/devkitpro/devkitPPC
# https://stackoverflow.com/a/38980986
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# Check if we're over SSH
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  SESSION_TYPE="remote/ssh"
else
  case $(ps -o comm= -p "$PPID") in
    sshd|*/sshd) SESSION_TYPE="remote/ssh";;
  esac
fi

# If we're not over SSH, we're most likely on a graphical session
if [ "$SESSION_TYPE" != "remote/ssh" ]; then
	# Hide some output from WINE
	export WINEDEBUG=-all
	# Use QT file dialog (1=QT; 0=GTK)
	export GTK_USE_PORTAL=1
	# Enable qt5ct to configure QT themes
	if [ "$DESKTOP_SESSION" = "plasma" ]; then
		export QT_QPA_PLATFORMTHEME=KDE
	else
		export QT_QPA_PLATFORMTHEME=qt5ct
		if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
			export QT_QPA_PLATFORM="wayland;xcb"
			export MOZ_ENABLE_WAYLAND=1
		fi
	fi

	# Symlink some folders to a directory in RAM
	rm -rf /home/sonico/Downloads/Firefox\ Downloads/Images
	if ! [ -d /zram/Images ]; then mkdir -p /zram/Images; fi
	ln -s /zram/Images /home/sonico/Downloads/Firefox\ Downloads/Images

	rm -rf /home/sonico/Downloads/Firefox\ Downloads/Torrents
	if ! [ -d /zram/Torrents ]; then mkdir -p /zram/Torrents; fi
	ln -s /zram/Torrents /home/sonico/Downloads/Firefox\ Downloads/Torrents

	yes 'n' | ln -s ~/.local/share/little-cache-files/* ~/.cache/ &>/dev/null

	if ! [[ "$XDG_CURRENT_DESKTOP" =~ (KDE|GNOME|XFCE4|Unity|Pantheon|Elementary|LXDE) ]]; then
		systemctl --user mask --runtime plasma-kglobalaccel.service
		systemctl --user mask --runtime plasma-baloorunner.service
		systemctl --user mask --runtime plasma-krunner.service
		systemctl --user mask --runtime plasma-kded.service
		systemctl --user mask --runtime plasma-kactivitymanagerd.service
		# systemctl --user mask --runtime plasma-xdg-desktop-portal-kde.service
		# xsettingsd &>/dev/null &
	elif [[ "$XDG_CURRENT_DESKTOP" == "KDE" ]]; then
		systemctl --user unmask plasma-kglobalaccel.service
		systemctl --user unmask plasma-baloorunner.service
		systemctl --user unmask plasma-krunner.service
		systemctl --user unmask plasma-kded.service
		systemctl --user unmask plasma-kactivitymanagerd.service
		# xsettingsd &>/dev/null &
	fi

	# KDE does not offer the cursor size 16, and defaults to 24
	# My cursor theme does not support that size, so logging into
	# KDE and going back to i3 breaks my cursor theme.
	sed -i "s/gtk-cursor-theme-size=24/gtk-cursor-theme-size=16/" ~/.config/gtk-3.0/settings.ini
	sed -i "s/gtk-cursor-theme-size=24/gtk-cursor-theme-size=16/" ~/.config/gtk-4.0/settings.ini
fi

source "$ZDOTDIR"/.zshenv
