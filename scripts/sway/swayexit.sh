#!/bin/bash

sysclose () {
	# stop_user_services
	kill -TERM "$(pidof firefox)"
	kill -TERM "$(pidof qbittorrent)"
	kill "$(pidof telegram-desktop)"
	kill "$(pidof clight)"
	kill "$(pidof wl-mpris-idle-inhibit)"
	swaymsg [app_id=".*"] kill
	swaymsg [class=".*"] kill
	kill -9 "$(pgrep -f "python")"
}


stop_user_services () {
	systemctl --user stop pipewire-input-filter-chain.service \
	pipewire-media-session.service pipewire-pulse.service \
	pipewire-pulse.socket pipewire.service pipewire.socket \
	wireplumber.service mpdscribble.service \
	mpDris2.service mpd.service playerctld.service \
	rangerbot.service userbot.service darkman.service \
	ssh-agent.service xdg-desktop-portal.service
}


case "$1" in
    exit)
	sysclose
	sleep 1 && swaymsg exit
	;;

    reboot)
	sysclose
	sleep 1 && systemctl reboot &
	;;

    shutdown)
	sysclose
	sleep 1 && systemctl poweroff -i &
	;;
esac
