# The env variables below can be override by the init script(e.g. S50launcher)

if [ -d /tmp/.xdg ]; then
	# Compatible with old S50launcher
	export XDG_RUNTIME_DIR=/tmp/.xdg
else
	export XDG_RUNTIME_DIR=/var/run
fi

# Comment out these to disable mirror mode
export WESTON_DRM_MIRROR=1
export WESTON_DRM_KEEP_RATIO=1

# Comment out this for atomic related functions, e.g. sprites
export WESTON_DISABLE_ATOMIC=1

# Comment out this for using drm modifier, e.g. ARM AFBC
export WESTON_DRM_DISABLE_MODIFIER=1

export QT_QPA_PLATFORM=wayland

# The kmssink has better performance but is more limited.
# export PREFERED_VIDEOSINK=kmssink
export PREFERED_VIDEOSINK=waylandsink

export QT_GSTREAMER_WIDGET_VIDEOSINK=${PREFERED_VIDEOSINK}
export QT_GSTREAMER_WINDOW_VIDEOSINK=${PREFERED_VIDEOSINK}
