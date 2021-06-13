#!/bin/sh
#

# check if file exist
#
CONTROLLO=$(cat /userdata/brightness.txt)

if [ -f /userdata/brightness.txt ] ; then

	if [ $CONTROLLO -ge 10 ] && [ $CONTROLLO -le 255 ]; then

		echo $(cat /userdata/brightness.txt) > /sys/class/backlight/backlight/brightness

		else
	 		rm /userdata/brightness.txt
			echo 165 > /sys/class/backlight/backlight/brightness
			echo 165 > /userdata/brightness.txt
			sync
		fi

	else
		
		echo 165 > /sys/class/backlight/backlight/brightness
		echo 165 > /userdata/brightness.txt
		sync

fi




