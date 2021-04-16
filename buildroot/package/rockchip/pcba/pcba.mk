# Rockchip's pcba porting for Linux


PCBA_SITE = $(TOPDIR)/../external/rk_pcba_test
PCBA_SITE_METHOD = local

ifeq ($(BR2_PACKAGE_RK3036_ECHO),y)
PCBA_CONF_OPTS = -DPCBA_3036=ON
endif

ifeq ($(BR2_PACKAGE_PX3SE),y)
ifeq ($(BR2_PACKAGE_PCBA_SCREEN),y)
PCBA_CONF_OPTS = -DPCBA_WITH_UI=ON
PCBA_DEPENDENCIES = zlib libpthread-stubs libpng libdrm
endif

PCBA_CONF_OPTS += -DPCBA_PX3SE=ON
endif


ifeq ($(BR2_PACKAGE_RK3308),y)
PCBA_CONF_OPTS = -DPCBA_3308=ON
endif

ifeq ($(BR2_PACKAGE_RK3229GVA),y)
PCBA_CONF_OPTS = -DPCBA_3229GVA=ON
endif

define PCBA_INSTALL_INIT_SYSV
$(INSTALL) -d -m 0755 $(TARGET_DIR)/data
$(INSTALL) -D -m 0755 $(@D)/rk_pcba_test/* $(TARGET_DIR)/data
endef

$(eval $(cmake-package))
