pacstrap -K /mnt base base-devel linux-zen linux-firmware intel-ucode git neovim reflector cryptsetup systemd-ukify plymouth sudo zsh networkmanager sddm kitty librewolf chezmoi
# TODO)) Script commands inside systemd-nspawn?
echo "Boot into the system for the first time, set root password with passwd command, then logout"
sleep 3
systemd-nspawn --pipe -D /mnt /bin/bash << EOF
passwd
logout
EOF

printf "rd.luks.name=$(blkid | grep "crypto_LUKS" | cut -d '\"' -f2)=System root=/dev/mapper/System rw splash quiet" >> /mnt/etc/kernel/cmdline

echo "Now boot into the system again and set it up"
systemd-nspawn --pipe -b -D /mnt /bin/bash << EOF

nvim /etc/locale.gen
locale-gen
systemd-firstboot --prompt
timedatectl set-ntp 1
sudo localectl set-x11-keymap us pc105 altgr-intl caps:backspace,lv3:lalt_switch,lv3:ralt_alt,shift:both_capslock 
printf '[multilib]\nInclude = /etc/pacman.d/mirrorlist\n\n[archlinuxcn]\nServer = https://repo.archlinuxcn.org/$arch' >> /etc/pacman.conf
reflector -l 10 --sort rate --save /etc/pacman.d/mirrorlist
pacman -Syyuu --noconfirm archlinux-keyring archlinuxcn-keyring
pacman -S --noconfirm paru
bootctl install
systemctl enable systemd-boot-update
printf "layout=uki\nuki_generator=ukify" >> /etc/kernel/install.conf
printf "[UKI]\nMicrocode=/boot/intel-ucode.img" >> /etc/kernel/uki.conf
printf "timeout 0\nconsole-mode auto" >| /boot/loader/loader.conf
sed -i "s#HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block filesystems fsck)#HOOKS=(base systemd plymouth sd-vconsole sd-encrypt autodetect microcode modconf kms keyboard block filesystems fsck)#" /etc/mkinitcpio.conf
useradd -m -G video,audio sonico -s /bin/zsh
echo "Set password for user sonico"
passwd sonico
systemctl enable NetworkManager
systemctl enable sddm
kernel-install add-all
mkdir -p /etc/tmpfiles.d
printf "d 		/zram		0755	sonico  sonico" >> /etc/tmpfiles.d/zram.conf
poweroff
EOF

echo "Boot into systemd-nspawn as sonico"
systemd-nspawn --pipe -b -D /mnt /bin/bash << EOF

paru -S --noconfirm pacman-hook-kernel-install neovim-symlinks catppuccin-sddm-theme-mocha yazi swayfx systemd-lock-handler sway-audio-idle-inhibit network-manager-applet
git clone https://github.com/Sonico98/dotfiles
mv dotfiles .dotfiles
# TODO)) use stow
poweroff
EOF
