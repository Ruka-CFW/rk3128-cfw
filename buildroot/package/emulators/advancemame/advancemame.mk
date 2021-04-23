################################################################################
#
# advancemame
#
################################################################################

ADVANCEMAME_VERSION = v3.9
ADVANCEMAME_SITE = $(call github,amadvance,advancemame,$(ADVANCEMAME_VERSION))
ADVANCEMAME_LICENSE = GPLv2

ADVANCEMAME_AUTORECONF = YES

define ADVANCEMAME_RUN_AUTOGEN
	cd $(@D) && PATH=$(BR_PATH) ./autogen.sh
endef

ADVANCEMAME_PRE_CONFIGURE_HOOKS += ADVANCEMAME_RUN_AUTOGEN

ADVANCEMAME_CONF_ENV += CFLAGS=-I$(STAGING_DIR)/usr/include/freetype2 LDFLAGS=-L$(STAGING_DIR)/usr/lib/

ADVANCEMAME_CONF_OPTS += \
	--prefix=$(TARGET_DIR)/usr \
	--exec-prefix=$(TARGET_DIR)/usr \
	--enable-pthreads \
	--disable-oss \
	--enable-mraw \
	--enable-mevent

ifeq ($(BR2_PACKAGE_SDL2),y)
ADVANCEMAME_DEPENDENCIES += sdl2
ADVANCEMAME_CONF_OPTS += \
	--enable-sdl2 \
	--with-sdl2-prefix=$(STAGING_DIR)/usr \
	--enable-jsdl \
	--enable-ksdl \
	--enable-msdl
else
ADVANCEMAME_CONF_OPTS += \
	--disable-jsdl \
	--disable-ksdl \
	--disable-msdl
endif

ifeq ($(BR2_PACKAGE_ALSA_LIB),y)
ADVANCEMAME_DEPENDENCIES += alsa-lib
ADVANCEMAME_CONF_OPTS += --enable-alsa
else
ADVANCEMAME_CONF_OPTS += --disable-alsa
endif

ifeq ($(BR2_PACKAGE_FREETYPE),y)
ADVANCEMAME_DEPENDENCIES += freetype
ADVANCEMAME_CONF_OPTS += \
	--enable-freetype \
	--with-freetype-prefix=$(STAGING_DIR)/usr
else
ADVANCEMAME_CONF_OPTS += --disable-freetype
endif

define ADVANCEMAME_ADD_PI_LINK
	$(SED) "s/^CONF_LIBS=.*/& -lbcm_host -lvcos -lvchostif/" $(@D)/Makefile ;
endef

ifeq ($(BR2_PACKAGE_RPI_USERLAND),y)
ADVANCEMAME_DEPENDENCIES += rpi-firmware rpi-userland
ADVANCEMAME_CONF_OPTS += --enable-vc \
	--with-vc-prefix=$(STAGING_DIR)/usr
ADVANCEMAME_POST_CONFIGURE_HOOKS += ADVANCEMAME_ADD_PI_LINK
endif

$(eval $(autotools-package))
