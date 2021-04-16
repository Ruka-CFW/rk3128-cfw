#!/bin/bash
VALORE=$(cat /sys/class/backlight/backlight/brightness)
if [ $VALORE -ge 20 ]; then
	echo $((VALORE-10)) > /sys/class/backlight/backlight/brightness
	echo $((VALORE-10)) > /userdata/brightness.txt
	sync
fi
