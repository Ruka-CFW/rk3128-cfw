################################################################################
#
# FLYCAST
#
################################################################################
# Version.: Commits on Mar 16, 2021
FLYCAST_VERSION = 0b6420d90a2cc4642f22b010cd074d8ba6c9fd02
FLYCAST_SITE = $(call github,flyinghead,flycast,$(FLYCAST_VERSION))
FLYCAST_LICENSE = GPLv2
FLYCAST_DEPENDENCIES = sdl2 libpng libzip

FLYCAST_PLATFORM = rockchip

FLYCAST_PLATFORM = armv7h neon
FLYCAST_EXTRA_ARGS += USE_GLES=1
FLYCAST_EXTRA_ARGS += USE_SDL=1 USE_SDLAUDIO=1
FLYCAST_EXTRA_ARGS += EXTRAFLAGS=-Wl,-lmali

define FLYCAST_UPDATE_INCLUDES
	sed -i "s+/opt/vc+$(STAGING_DIR)/usr+g" $(@D)/shell/linux/Makefile
	sed -i "s+sdl2-config+$(STAGING_DIR)/usr/bin/sdl2-config+g" $(@D)/shell/linux/Makefile
endef

FLYCAST_PRE_CONFIGURE_HOOKS += FLYCAST_UPDATE_INCLUDES

define FLYCAST_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" -C $(@D)/shell/linux -f Makefile \
		platform="$(FLYCAST_PLATFORM)" $(FLYCAST_EXTRA_ARGS)
endef

define FLYCAST_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/shell/linux/nosym-reicast.elf \
		$(TARGET_DIR)/usr/bin/flycast
endef

$(eval $(generic-package))

