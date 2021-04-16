# Rockchip's liblog porting from Android
# Author : Cody Xie <cody.xie@rock-chips.com>

LIBLOG_SITE = $(TOPDIR)/../external/liblog
LIBLOG_SITE_METHOD = local
LIBLOG_INSTALL_STAGING = YES

$(eval $(cmake-package))
