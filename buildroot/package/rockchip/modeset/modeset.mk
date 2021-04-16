# Rockchip's modeset(Multimedia Processing Platform)
MODESET_SITE = $(TOPDIR)/package/rockchip/modeset/src
MODESET_VERSION = release
MODESET_SITE_METHOD = local

MODESET_CONF_DEPENDENCIES += libdrm jpeg

ifeq ($(BR2_PACKAGE_MODESET_SWAP_RB),y)
    MODESET_CONF_OPTS += "-DMODESET_SWAP_RB=y"
endif

define MODESET_COPY_BOOTANIMATION_RESOURCE
	mkdir -p $(TARGET_DIR)/mnt/bootanimation
	cp -rf  $(@D)/bootanimation $(TARGET_DIR)/mnt/
	cp -f $(@D)/S01bootanimation $(TARGET_DIR)/etc/init.d/
endef

MODESET_POST_INSTALL_TARGET_HOOKS += MODESET_COPY_BOOTANIMATION_RESOURCE

$(eval $(cmake-package))
