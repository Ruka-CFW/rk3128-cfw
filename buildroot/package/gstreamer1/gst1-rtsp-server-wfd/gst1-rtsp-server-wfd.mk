################################################################################
#
# gst1-rtsp-server-wfd
#
################################################################################

GST1_RTSP_SERVER_WFD_VERSION = c76d6b78893cbc3f3bdd650ea816cf74d2ca2402
GST1_RTSP_SERVER_WFD_SITE = $(call github,albfan,gst-rtsp-server-wfd,$(GST1_RTSP_SERVER_WFD_VERSION))
GST1_RTSP_SERVER_WFD_LICENSE = LGPL-2.0+
GST1_RTSP_SERVER_WFD_LICENSE_FILES = COPYING COPYING.LIB
GST1_RTSP_SERVER_WFD_INSTALL_STAGING = YES
GST1_RTSP_SERVER_WFD_DEPENDENCIES = \
	host-pkgconf \
	gstreamer1 \
	gst1-plugins-base \
	gst1-plugins-good

GST1_RTSP_SERVER_WFD_AUTORECONF := YES

ifeq ($(BR2_PACKAGE_LIBCGROUP),y)
GST1_RTSP_SERVER_WFD_DEPENDENCIES += libcgroup
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_BAD),y)
GST1_RTSP_SERVER_WFD_DEPENDENCIES += gst1-plugins-bad
endif

$(eval $(autotools-package))
