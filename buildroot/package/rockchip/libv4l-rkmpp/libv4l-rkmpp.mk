################################################################################
#
# libv4l-rkmpp
#
################################################################################

LIBV4L_RKMPP_SITE = git://github.com/JeffyCN/libv4l-rkmpp.git
LIBV4L_RKMPP_VERSION = 1.3.3
LIBV4L_RKMPP_SITE_METHOD = git
LIBV4L_RKMPP_AUTORECONF = YES

LIBV4L_RKMPP_LICENSE = LGPL-2.1
LIBV4L_RKMPP_LICENSE_FILES = COPYING

LIBV4L_RKMPP_DEPENDENCIES = libv4l mpp

$(eval $(autotools-package))
