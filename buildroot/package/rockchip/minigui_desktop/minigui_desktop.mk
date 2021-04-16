MINIGUI_DESKTOP_VERSION = develop
MINIGUI_DESKTOP_SITE = $(TOPDIR)/../external/minigui_desktop
MINIGUI_DESKTOP_SITE_METHOD = local

MINIGUI_DESKTOP_LICENSE = Apache V2.0
MINIGUI_DESKTOP_LICENSE_FILES = NOTICE
CC="$(TARGET_CC)"
PROJECT_DIR="$(@D)"

MINIGUI_DESKTOP_DEPENDENCIES = minigui deviceio rtc_demo

MINIGUI_MAKE_ENV=$(TARGET_MAKE_ENV)

ifeq ($(BR2_PACKAGE_FFMPEG_SWSCALE),y)
MINIGUI_MAKE_ENV += ENABLE_VIDEO=1
endif

define MINIGUI_DESKTOP_IMAGE_COPY
        mkdir -p $(TARGET_DIR)/usr/local/share/
        cp -r $(PROJECT_DIR)/minigui $(TARGET_DIR)/usr/local/share/
        cp -r $(PROJECT_DIR)/S99minigui_app $(TARGET_DIR)/etc/init.d/S99minigui_app
        cp -r $(PROJECT_DIR)/minigui/MiniGUI.cfg.$(MINIGUI_TARGET) \
			  $(TARGET_DIR)/etc/MiniGUI.cfg
	$(SED) "s/event0/$(call qstrip,$(BR2_PACKAGE_MINIGUI_RKKEYBOARD_EVENT))/" \
		$(TARGET_DIR)/etc/MiniGUI.cfg
endef

define MINIGUI_DESKTOP_BUILD_CMDS
	$(MINIGUI_MAKE_ENV) $(MAKE) -C $(@D) CC="$(TARGET_CC)" $(MINIGUI_DESKTOP_OPT)
endef

define MINIGUI_DESKTOP_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0644 -D $($(PKG)_PKGDIR)/61-powersupply.rules $(TARGET_DIR)/lib/udev/rules.d/
        $(INSTALL) -D -m 755 $(@D)/minigui_desktop $(TARGET_DIR)/usr/bin/ && $(MINIGUI_DESKTOP_IMAGE_COPY)
endef

$(eval $(generic-package))
