# Set ZSH config directory
export ZDOTDIR=${HOME}/.config/zsh

# Try to make all programs respect the cursor theme (GIMP...)
export XCURSOR_THEME="Bibata-Rainbow-Modern"

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
export GNUPGHOME=${HOME}/.gnupg
# Disable dotnet Telemetry
export DOTNET_CLI_TELEMETRY_OPTOUT=1
# Devkitpro
export DEVKITPRO=/opt/devkitpro
export DEVKITARM=/opt/devkitpro/devkitARM
export DEVKITPPC=/opt/devkitpro/devkitPPC
# https://stackoverflow.com/a/38980986
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
# Enable java font antialising, GTK Look and Feel, Better 2D Performance
export JDK_JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=setting -Dswing.aatext=true -Dsun.java2d.opengl=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'
# SILENT_JAVA_OPTIONS="$JDK_JAVA_OPTIONS"
# unset JDK_JAVA_OPTIONS
# alias java='java "$SILENT_JAVA_OPTIONS"'

source "$ZDOTDIR"/.zshenv
