#!/bin/sh

export LC_ALL='en_US.utf8'
export WESTON_DRM_MIRROR=0
export WESTON_DRM_PREFER_EXTERNAL=1

# for QLauncher wayland
mkdir -p /tmp/.xdg &&  chmod 0700 /tmp/.xdg
export XDG_RUNTIME_DIR=/tmp/.xdg
weston --tty=2 --idle-time=0 &

sleep 5

if [ `cat /sys/class/drm/card0-HDMI-A-1/status` == "connected" ]; then
  ra_config="/mnt/sdcard/settings/retroarch/retroarch_hdmi.cfg"
  amixer cset name='Playback Path' 'OFF'

else
  amixer cset name='Playback Path' 'SPK'

  modes_files=`find /sys/ -name "modes" 2>/dev/null`
  mode=`for f in $modes_files; do cat $f | grep "U:"; done`

  case "$mode" in
    U:960x544p-0)
      ra_config="/sdcard/settings/retroarch/retroarch_ps5000.cfg"
      ;;
    U:1024x600p-0)
      # start brightness control
      /usr/local/share/scripts/bc.sh
      ra_config="/sdcard/settings/retroarch/retroarch.cfg"
      ;;
    U:800x480p-0)
      # start brightness control
      /usr/local/share/scripts/bc.sh
      ra_config="/sdcard/settings/retroarch/retroarch_v3.cfg"
      ;;
  esac
fi

#( retroarch -c ${ra_config}; poweroff; ) &
retroarch -c ${ra_config} &