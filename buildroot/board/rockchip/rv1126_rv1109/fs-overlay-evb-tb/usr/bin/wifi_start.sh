#!/bin/sh
WIFISSID=$1
WIFIPWD=$2
CONF=/tmp/wpa_supplicant.conf

cp /etc/wpa_supplicant.conf /tmp/
echo "connect to WiFi ssid: $WIFISSID, Passwd: $WIFIPWD"
sed -i "s/SSID/$WIFISSID/g" $CONF
sed -i "s/PASSWORD/$WIFIPWD/g" $CONF
wpa_cli -i wlan0 disconnect
killall wpa_supplicant
wpa_supplicant -B -i wlan0 -c $CONF
