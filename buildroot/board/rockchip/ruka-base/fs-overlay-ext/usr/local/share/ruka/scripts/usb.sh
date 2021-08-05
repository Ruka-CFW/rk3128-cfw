#!/bin/sh

export LC_ALL='en_US.utf8'
export WESTON_DRM_MIRROR=0
export WESTON_DRM_PREFER_EXTERNAL=1
export HOME=/userdata/system

# Set up SDL ASSERT workaround (disable it)
export SDL_ASSERT=always_ignore

# XDG_RUNTIME need to be set for wayland
mkdir -p /tmp/.xdg &&  chmod 0700 /tmp/.xdg
export XDG_RUNTIME_DIR=/tmp/.xdg
weston --tty=2 --idle-time=0 &

sleep 2

export RA_CONFIG_FOLDER=/mnt/sdcard/configs/ruka

if [ `cat /sys/class/drm/card0-HDMI-A-1/status` == "connected" ]; then
  ra_config="${RA_CONFIG_FOLDER}/retroarch_hdmi.cfg"
  amixer cset name='Playback Path' 'OFF'

else
  amixer cset name='Playback Path' 'SPK'

  modes_files=`find /sys/ -name "modes" 2>/dev/null`
  mode=`for f in $modes_files; do cat $f | grep "U:"; done`

  case "$mode" in
    U:960x544p-0)
      ra_config="${RA_CONFIG_FOLDER}/retroarch_ps5000.cfg"
      ;;
    U:1024x600p-0)
      # start brightness control
      /usr/local/share/scripts/bc.sh
      ra_config="${RA_CONFIG_FOLDER}/retroarch.cfg"
      ;;
    U:800x480p-0)
      # start brightness control
      /usr/local/share/scripts/bc.sh
      ra_config="${RA_CONFIG_FOLDER}/retroarch_v3.cfg"
      ;;
  esac
fi

#( retroarch -c ${ra_config}; poweroff; ) &
retroarch -c ${ra_config} &
