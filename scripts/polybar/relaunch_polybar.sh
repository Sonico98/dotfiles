#!/bin/bash

check_topbar=$(pgrep -f "topbar" | wc -l)
check_systray=$(pgrep -f "systray" | wc -l)
check_polybar=$(pidof polybar | wc -w)

case $1 in
	m)
		if [ $check_topbar -gt 0 ]; then
			kill -USR1 "$(pgrep -f 'topbar')" &> /dev/null
		else
			polybar topbar &> /dev/null &
		fi
		;;
	t)
		(pkill -f -9 "hideIt.sh") &> /dev/null

		if [ $check_systray -gt 0 ]; then
			kill -USR1 "$(pgrep -f 'systray')" &> /dev/null
		else
			polybar -c $HOME/.config/polybar/config_systray systray &> /dev/null &
		fi

		sleep 2 && (hideIt.sh --name 'polybar-systray_LVDS1' --region 450x0+450+0 -d top -p 0 -s 1 -i 1) &> /dev/null &
		;;
	b)	
		(pkill -f -9 "hideIt.sh") &> /dev/null

		if [ $check_polybar -gt 1 ]; then
			pkill -USR1 polybar &> /dev/null &
		else
			polybar topbar &> /dev/null &
			polybar -c $HOME/.config/polybar/config_systray systray &> /dev/null &
		fi

		sleep 2 && (hideIt.sh --name 'polybar-systray_LVDS1' --region 450x0+450+0 -d top -p 0 -s 1 -i 1) &> /dev/null &
		;;
esac

exit 0
