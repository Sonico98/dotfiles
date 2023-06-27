#!/bin/bash

sysclose () {
	sync_cache_to_hdd
	rm -rf /tmp/lockscreen
	kill -TERM "$(pidof chrome)"
	kill -TERM "$(pidof qbittorrent)"
	kill "$(pidof Telegram)"
	kill "$(pidof clight)"
	kill -9 "$(pgrep -f "python")"
	kill -9 "$(pgrep -f "hideIt.sh")"
	i3-msg [class=".*"] kill
}


sync_cache_to_hdd () {
	rsync -a --update --existing ~/.cache/paru/clone/ ~/.local/share/little-cache-files/cache/
}


stop_pipewire () {
	systemctl --user stop pipewire-input-filter-chain.service \
	pipewire-media-session.service pipewire-pulse.service \
	pipewire-pulse.socket pipewire.service pipewire.socket \
	mpdscribble.service mpDris2.service rangerbot.service; \
}


get_processes () {
	ps -U "$USER" | grep -E -v "Plex" | grep -E -v "i3" | \
		grep -E -v "qbittorrent" | awk '{print $1}' | grep -E -v 'PID' >| /tmp/processes
}


case "$1" in
    exit)
	sysclose
	sleep 0.4 && get_processes
	cat /tmp/processes | xargs -t kill
	sleep 1 && cat /tmp/processes | xargs -t kill -9
	rm -f /tmp/processes
	i3-msg exit
	;;

    reboot)
	sysclose
	sleep 0.4 && get_processes
	stop_pipewire
	cat /tmp/processes | xargs -t kill
	sleep 1 && cat /tmp/processes | xargs -t kill -9
	systemctl reboot
	;;

    shutdown)
	sysclose
	sleep 0.4 && get_processes
	stop_pipewire
	cat /tmp/processes | xargs -t kill
	sleep 1 && cat /tmp/processes | xargs -t kill -9
	systemctl poweroff -i
	;;
esac
