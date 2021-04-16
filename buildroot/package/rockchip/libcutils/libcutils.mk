# Rockchip's libcutils porting from Android
# Author : Cody Xie <cody.xie@rock-chips.com>

LIBCUTILS_SITE = $(TOPDIR)/../external/libcutils
LIBCUTILS_SITE_METHOD = local
LIBCUTILS_DEPENDENCIES += liblog
LIBCUTILS_VERSION = 2c61c38
LIBCUTILS_INSTALL_STAGING = YES

ifneq ($(BR2_ARM_CPU_ARMV4)$(BR2_ARM_CPU_ARMV5),)
LIBCUTILS_CONF_OPTS += -DHAVE_LDREX_STREX=0 -DSMP=0
endif

$(eval $(cmake-package))
