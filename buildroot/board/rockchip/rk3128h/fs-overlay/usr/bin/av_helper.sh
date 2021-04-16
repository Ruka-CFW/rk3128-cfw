#!/bin/bash

CONNECTOR_FILE=/tmp/drm_connector.cfg
MODE_FILE=/tmp/drm_mode.cfg
PLAYBACK_FILE=/tmp/alsa_device.cfg

drm_get_type()
{
	BASE_NAME=${1%-*}

	case $BASE_NAME in
		HDMI-*)
			echo hdmi
			return
			;;
		Unknown|VGA|DVI-*|DP|HDMI-*|TV)
			echo external 
			return
			;;
	esac

	echo internal
}

drm_init_connector()
{
	ID=$1
	ENCODER=$2
	STATUS=$3
	NAME=$4
	TYPE=$(drm_get_type $NAME)

	ENABLED=enabled
	[ "$ENCODER" -eq 0 ] && ENABLED=disabled

	export DRM_${ID}_ID=$ID
	export DRM_${ID}_NAME=$NAME
	export DRM_${ID}_TYPE=$TYPE
	export DRM_${ID}_ENABLED=$ENABLED
	export DRM_${ID}_STATUS=$STATUS
}

drm_init_connectors()
{
	type modetest > /dev/null || exit -1

	STATUS=${1:-connected|disconnected}
	TEMP=$(mktemp)
	modetest -M rockchip -c|grep -wE "$STATUS" > $TEMP

	export DRM_CONNECTORS=$(cat $TEMP|awk '{print $1}'|xargs)

	while read LINE;do
		drm_init_connector $LINE
	done < $TEMP
	rm $TEMP
}

drm_get_sys_property()
{
	ID=$1
	PROP=$2
	SYS_PATH=/sys/class/drm/card0-$(drm_get_properties $ID NAME)

	case $PROP in
		MODE)
			grep -oE "[0-9]+x[0-9]+" ${SYS_PATH}/mode
			;;
		MODES)
			grep -oE "[0-9]+x[0-9]+" ${SYS_PATH}/modes|uniq|xargs
			;;
	esac
}

drm_get_properties()
{
	ID=$1
	shift

	typeset -u PROP
	while true;do
		PROP=$1
		shift

		case $PROP in
			MODE*)
				VAL=$(drm_get_sys_property $ID $PROP)
				echo -n $VAL
				;;
			*)
				ENV=DRM_${ID}_${PROP}
				eval echo -n \$$ENV
				;;
		esac

		[ -n "$1" ] || break
		echo -n " "
	done
	echo
}

drm_list_connectors()
{
	for id in $DRM_CONNECTORS;do
		drm_get_properties $id ID NAME TYPE STATUS MODE
		echo -n "  "
		drm_get_properties $id MODES
	done
}

drm_id_from_option()
{
	VAL=$1
	STATUS=$2

	for id in $DRM_CONNECTORS;do
		if [ -n "$STATUS" ];then
			drm_get_properties $id STATUS|grep -wq connected \
				|| continue
		fi

		[ $id == $VAL ] && echo $id && return

		drm_get_properties $id TYPE|grep -iwq "$VAL" && \
			echo $id && return
		drm_get_properties $id NAME|grep -iq "^$VAL" && \
			echo $id && return
	done
}

drm_set_connector()
{
	ID=$1
	MODE=$2
	CHANGED=

	echo "Connector: $ID"
	if ! grep -wq "$ID" $CONNECTOR_FILE 2>/dev/null;then
		echo $ID > $CONNECTOR_FILE
		CHANGED=1
	fi

	if [ -n "$MODE" ];then
		echo "Mode: $MODE"
		if ! grep -wq "$MODE" $MODE_FILE 2>/dev/null;then
			echo $MODE > $MODE_FILE
			CHANGED=1
		fi
	fi

	[ $CHANGED ] && fuser -k -SIGUSR2 /dev/dri/card0
}

alsa_get_type()
{
	DESC="$@"

	HDMI_CODECS="i2s-hifi spdif-hifi HDMI"
	for codec in $HDMI_CODECS;do
		if echo $DESC|grep -q "$codec";then
			echo HDMI
			return;
		fi
	done

	if echo $DESC|grep -iq usb;then
		echo USB
		return;
	fi

	echo INTERNAL
}

alsa_init_playback()
{
	ID=$1
	shift

	DESC="$@"
	TYPE=$(alsa_get_type $DESC)

	export ALSA_${ID}_ID=$ID
	export ALSA_${ID}_TYPE=$TYPE
	export ALSA_${ID}_DESC="$DESC"
}

alsa_init_playbacks()
{
	[ -f /proc/asound/pcm ] || exit -1

	TEMP=$(mktemp)
	grep playback /proc/asound/pcm|sed "s/^0\([0-9]\)-0\([0-9]\):/\1_\2/"> $TEMP

	export ALSA_PLAYBACKS=$(cat $TEMP|awk '{print $1}'|xargs)

	while read LINE;do
		alsa_init_playback $LINE
	done < $TEMP
	rm $TEMP
}

alsa_get_properties()
{
	ID=$1
	shift

	typeset -u PROP
	while true;do
		PROP=$1
		shift

		case $PROP in
			NAME)
				VAL=plughw:${ID//_/,}
				echo -n $VAL
				;;
			*)
				ENV=ALSA_${ID}_${PROP}
				eval echo -n \$$ENV
				;;
		esac

		[ -n "$1" ] || break
		echo -n " "
	done
	echo
}

alsa_list_playbacks()
{
	for id in $ALSA_PLAYBACKS;do
		alsa_get_properties $id ID NAME TYPE
		echo -n "  "
		alsa_get_properties $id DESC
	done
}

alsa_id_from_option()
{
	VAL=$1

	for id in $ALSA_PLAYBACKS;do
		[ $id == $VAL ] && echo $id && return

		alsa_get_properties $id NAME|grep -iq "$VAL" \
			&& echo $id && return
		alsa_get_properties $id TYPE|grep -iwq "$VAL" \
			&& echo $id && return
	done
}

alsa_set_playback()
{
	NAME=$1

	echo "Playback: $NAME"
	if ! grep -wq "$NAME" $PLAYBACK_FILE 2>/dev/null;then
		echo $NAME > $PLAYBACK_FILE
		fuser -k -SIGUSR1 /dev/snd/pcmC*p
	fi
}
