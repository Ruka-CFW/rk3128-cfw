#!/bin/bash

if [ `cat /sys/class/drm/card0-HDMI-A-1/status` == "disconnected" ]; then
	amixer cset name='Master Playback Volume' `cat /sys/devices/platform/adc-pot/scaled`
else
	amixer cset name='HDMI Playback Volume' `cat /sys/devices/platform/adc-pot/scaled`
fi
