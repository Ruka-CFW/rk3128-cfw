#!/bin/sh
#
# Volume control
#
# by LV-426

if [[ ! -f /userdata/sound.state ]] ; then
	cp /usr/local/share/scripts/sound.default /userdata/sound.state
fi

alsactl --file /sdcard/RetroArch/sound.state restore

evtest /dev/input/event0 |while read line ;

do
	echo $line | if grep -q KEY_VOLUMEUP.*1 ; then
		amixer -q sset Master 5+ && alsactl --file /sdcard/RetroArch/sound.state store
			else
	echo $line | if grep -q KEY_VOLUMEDOWN.*1 ;then
		amixer -q sset Master 5- && alsactl --file /sdcard/RetroArch/sound.state store
			fi ;
	fi
done
