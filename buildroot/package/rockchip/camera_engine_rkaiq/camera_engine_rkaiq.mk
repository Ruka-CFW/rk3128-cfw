################################################################################
#
# Rockchip Camera Engine RKaiq For Linux
#
################################################################################

ifeq ($(BR2_PACKAGE_CAMERA_ENGINE_RKAIQ), y)
CAMERA_ENGINE_RKAIQ_VERSION = 1.0
CAMERA_ENGINE_RKAIQ_SITE = $(TOPDIR)/../external/camera_engine_rkaiq
CAMERA_ENGINE_RKAIQ_SITE_METHOD = local
CAMERA_ENGINE_RKAIQ_INSTALL_STAGING = YES

CAMERA_ENGINE_RKAIQ_LICENSE = Apache V2.0
CAMERA_ENGINE_RKAIQ_LICENSE_FILES = NOTICE

CAMERA_ENGINE_RKAIQ_DEPENDENCIES = host-camera_engine_rkaiq

CAMERA_ENGINE_RKAIQ_TARGET_INSTALL_DIR = $(TARGET_DIR)

CAMERA_ENGINE_RKAIQ_CONF_OPTS = -DBUILDROOT_BUILD_PROJECT=TRUE -DARCH=$(BR2_ARCH)

ifeq ($(BR2_PACKAGE_RK_OEM), y)
ifneq ($(BR2_PACKAGE_THUNDERBOOT), y)
CAMERA_ENGINE_RKAIQ_INSTALL_TARGET_OPTS = DESTDIR=$(BR2_PACKAGE_RK_OEM_INSTALL_TARGET_DIR) install/fast
CAMERA_ENGINE_RKAIQ_DEPENDENCIES += rk_oem
CAMERA_ENGINE_RKAIQ_TARGET_INSTALL_DIR = $(call qstrip,$(BR2_PACKAGE_RK_OEM_INSTALL_TARGET_DIR))
endif
endif

ifeq ($(BR2_PACKAGE_CAMERA_ENGINE_RKAIQ_IQFILE_USE_BIN), y)

define HOST_CAMERA_ENGINE_RKAIQ_BUILD_CMDS
	cd $(@D)/rkisp_parser_demo/build/linux && ./make-Makefiles.bash && $(MAKE)
endef

define HOST_CAMERA_ENGINE_RKAIQ_INSTALL_CMDS
	$(INSTALL) -D -m  755 $(@D)/rkisp_parser_demo/build/linux/exe/debug/rkisp_parser  $(HOST_DIR)/bin
endef

RKISP_PARSER_HOST_BINARY = $(HOST_DIR)/bin/rkisp_parser

define conver_iqfiles
dir=`echo $(1)`; \
iqfile=`echo $(2)`; \
if [[ -z "$$iqfile" ]]; then \
	echo "## conver iqfiles"; \
	for i in $$dir/*.xml; do \
		echo "### conver iqfiles: $$i"; \
		$(RKISP_PARSER_HOST_BINARY) $$i; \
	done; \
else  \
	echo "### conver iqfile: $$dir/$$iqfile"; \
	$(RKISP_PARSER_HOST_BINARY) $$dir/$$iqfile; \
fi;
endef

define IQFILE_CONVER_CMD
        $(foreach iqfile, $(call qstrip,$(BR2_PACKAGE_CAMERA_ENGINE_RKAIQ_IQFILE)),
		$(call conver_iqfiles, $(@D)/iqfiles, $(iqfile))
        )
endef

define IQFILES_CONVER_CMD
	$(call conver_iqfiles, $(@D)/iqfiles)
endef

	ifneq ($(call qstrip,$(BR2_PACKAGE_CAMERA_ENGINE_RKAIQ_IQFILE)),)
		CAMERA_ENGINE_RKAIQ_PRE_BUILD_HOOKS += IQFILE_CONVER_CMD
	else
		CAMERA_ENGINE_RKAIQ_PRE_BUILD_HOOKS += IQFILES_CONVER_CMD
	endif
	CAMERA_ENGINE_RKAIQ_IQFILE = *.bin
else
	ifneq ($(call qstrip,$(BR2_PACKAGE_CAMERA_ENGINE_RKAIQ_IQFILE)),)
		CAMERA_ENGINE_RKAIQ_IQFILE = $(call qstrip,$(BR2_PACKAGE_CAMERA_ENGINE_RKAIQ_IQFILE))
	else
		CAMERA_ENGINE_RKAIQ_IQFILE = *.xml
	endif
endif

define INSTALL_FAKE_CAMERA_IQFILE_CMD
       $(INSTALL) -D -m  644 $(@D)/iqfiles/$(BR2_PACKAGE_CAMERA_ENGINE_RKAIQ_FAKE_CAMERA_IQFILE) \
                $(CAMERA_ENGINE_RKAIQ_TARGET_INSTALL_DIR)/etc/iqfiles/FakeCamera.xml
endef
ifneq ($(call qstrip,$(BR2_PACKAGE_CAMERA_ENGINE_RKAIQ_FAKE_CAMERA_IQFILE)),)
        CAMERA_ENGINE_RKAIQ_PRE_BUILD_HOOKS += INSTALL_FAKE_CAMERA_IQFILE_CMD
endif

ifeq ($(BR2_PACKAGE_CAMERA_ENGINE_RKAIQ_RKISP_DEMO), y)
CAMERA_ENGINE_RKAIQ_CONF_OPTS += -DENABLE_RKISP_DEMO=ON
endif

define CAMERA_ENGINE_RKAIQ_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) DESTDIR=$(STAGING_DIR) $(MAKE) -C $($(PKG)_BUILDDIR) install
endef

define CAMERA_ENGINE_RKAIQ_INSTALL_TARGET_CMDS
	mkdir -p $(CAMERA_ENGINE_RKAIQ_TARGET_INSTALL_DIR)/etc/iqfiles/
	mkdir -p $(CAMERA_ENGINE_RKAIQ_TARGET_INSTALL_DIR)/usr/lib/
	mkdir -p $(CAMERA_ENGINE_RKAIQ_TARGET_INSTALL_DIR)/usr/bin/
	$(TARGET_MAKE_ENV) DESTDIR=$(CAMERA_ENGINE_RKAIQ_TARGET_INSTALL_DIR) $(MAKE) -C $($(PKG)_BUILDDIR) install
	$(foreach iqfile,$(CAMERA_ENGINE_RKAIQ_IQFILE),
		$(INSTALL) -D -m  644 $(@D)/iqfiles/$(iqfile) \
		$(CAMERA_ENGINE_RKAIQ_TARGET_INSTALL_DIR)/etc/iqfiles/
	)
endef

$(eval $(cmake-package))
$(eval $(host-generic-package))

endif
