export GST_DEBUG_NO_COLOR=1

# Use below env variables to configure kmssink plane ZPOS.
# export KMSSINK_PLANE_ZPOS=0
# export KMSSINK_PLANE_ON_TOP=1
# export KMSSINK_PLANE_ON_BOTTOM=1

# There's an extra vsync waiting in kmssink, which is only needed for BSP 4.4
# kernel(due to ecac2033831e FROMLIST: drm: skip wait on vblank for set plane).
# Skip it would bring better performance with frame dropping.
# export KMSSINK_DISABLE_VSYNC=1

# Put video surface above UI window in waylandsink.
# export WAYLANDSINK_PLACE_ABOVE=1

# Preferred formats for V4L2
export GST_V4L2_PREFERRED_FOURCC=YU12:NV12

# Preferred sinks for playbin3(autoaudiosink/autovideosink) and playbin.
# export AUTOAUDIOSINK_PREFERRED=alsasink
# export AUTOVIDEOSINK_PREFERRED=waylandsink
# export PLAYBIN2_PREFERRED_AUDIOSINK=alsasink
# export PLAYBIN2_PREFERRED_VIDEOSINK=waylandsink

# Try RGA 2D accel in videoconvert, videoscale and videoflip.
# NOTE: Might not success, and might behave different from the official plugin.
export GST_VIDEO_CONVERT_USE_RGA=1
export GST_VIDEO_FLIP_USE_RGA=1

# Default rotation for camerabin2:
# clockwise(90)|rotate-180|counterclockwise(270)|horizontal-flip|vertical-flip
# export CAMERA_FLIP=clockwise
if [ $CAMERA_FLIP ]; then
	CAMERA_FILTER="videoflip method=$CAMERA_FLIP"
	export CAMERABIN2_PREVIEW_FILTER=$CAMERA_FILTER
	export CAMERABIN2_IMAGE_FILTER=$CAMERA_FILTER
	export CAMERABIN2_VIDEO_FILTER=$CAMERA_FILTER
	export CAMERABIN2_VIEWFINDER_FILTER=$CAMERA_FILTER
fi
