################################################################################
#
# libnghttp2.mk
#
################################################################################

LIBNGHTTP2_VERSION = v1.23.1
LIBNGHTTP2_SITE = $(call github,nghttp2,nghttp2,$(LIBNGHTTP2_VERSION))
LIBNGHTTP2_LICENSE = ISC
LIBNGHTTP2_LICENSE_FILES = COPYING
LIBNGHTTP2_INSTALL_STAGING = YES
LIBNGHTTP2_INSTALL_TARGET  = YES
LIBNGHTTP2_AUTORECONF = YES

$(eval $(autotools-package))
