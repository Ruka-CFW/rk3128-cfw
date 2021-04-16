# Rockchip's MPP(Multimedia Processing Platform)
MPP_SITE = $(TOPDIR)/../external/mpp
MPP_VERSION = release
MPP_SITE_METHOD = local

MPP_CONF_OPTS = "-DRKPLATFORM=ON"
MPP_CONF_DEPENDENCIES += libdrm

MPP_INSTALL_STAGING = YES

ifeq ($(BR2_PACKAGE_MPP_ALLOCATOR_DRM),y)
MPP_CONF_OPTS += "-DHAVE_DRM=ON"
endif

ifeq ($(BR2_PACKAGE_MPP_TESTS),y)
MPP_CONF_OPTS += "-DBUILD_TEST=ON"
endif

define MPP_LINK_GIT
	rm -rf $(@D)/.git
	ln -s $(SRCDIR)/.git $(@D)/
endef

MPP_POST_RSYNC_HOOKS += MPP_LINK_GIT

ifeq ($(BR2_PACKAGE_RK3328),y)
define MPP_H265_SUPPORTED_FIRMWARE
	mkdir -p $(TARGET_DIR)/lib/firmware/

	if test -e $(MPP_SITE)/../rktoolkit/monet.bin ; then \
		$(INSTALL) -m 0644 -D $(MPP_SITE)/../rktoolkit/monet.bin \
			$(TARGET_DIR)/lib/firmware/ ; \
	else \
		$(INSTALL) -m 0644 -D package/rockchip/mpp/monet.bin \
			$(TARGET_DIR)/lib/firmware/ ; \
	fi
endef
MPP_POST_INSTALL_TARGET_HOOKS += MPP_H265_SUPPORTED_FIRMWARE
endif

ifeq ($(BR2_PACKAGE_RK_OEM), y)
ifneq ($(BR2_PACKAGE_THUNDERBOOT), y)
MPP_INSTALL_TARGET_OPTS = DESTDIR=$(BR2_PACKAGE_RK_OEM_INSTALL_TARGET_DIR) install/fast
endif
endif

$(eval $(cmake-package))
