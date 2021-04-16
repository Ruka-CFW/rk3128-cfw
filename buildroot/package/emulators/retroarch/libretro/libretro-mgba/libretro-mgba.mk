################################################################################
#
# MGBA
#
################################################################################
# Version.: Release on Oct 29, 2020
LIBRETRO_MGBA_VERSION = 0.8.4
LIBRETRO_MGBA_SITE = $(call github,mgba-emu,mgba,$(LIBRETRO_MGBA_VERSION))
LIBRETRO_MGBA_LICENSE = MPLv2.0

LIBRETRO_MGBA_DEPENDENCIES = libzip libpng zlib

LIBRETRO_MGBA_CONF_OPTS += -DBUILD_LIBRETRO=ON
LIBRETRO_MGBA_CONF_OPTS += -DSKIP_LIBRARY=ON
LIBRETRO_MGBA_CONF_OPTS += -DBUILD_QT=OFF
LIBRETRO_MGBA_CONF_OPTS += -DBUILD_SDL=OFF
LIBRETRO_MGBA_CONF_OPTS += -DUSE_DISCORD_RPC=OFF
LIBRETRO_MGBA_CONF_OPTS += -DUSE_GDB_STUB=OFF
LIBRETRO_MGBA_CONF_OPTS += -DUSE_FFMPEG=OFF
LIBRETRO_MGBA_CONF_OPTS += -DUSE_LZMA=OFF
LIBRETRO_MGBA_CONF_OPTS += -DUSE_SQLITE3=OFF
LIBRETRO_MGBA_CONF_OPTS += -DUSE_DEBUGGERS=OFF
LIBRETRO_MGBA_CONF_OPTS += -DUSE_EDITLINE=OFF
LIBRETRO_MGBA_CONF_OPTS += -DUSE_ELF=OFF
LIBRETRO_MGBA_CONF_OPTS += -DBUILD_GL=OFF
LIBRETRO_MGBA_CONF_OPTS += -DBUILD_GLES2=OFF
LIBRETRO_MGBA_CONF_OPTS += -DBUILD_GLES3=OFF
LIBRETRO_MGBA_CONF_OPTS += -DUSE_EPOXY=OFF
LIBRETRO_MGBA_CONF_OPTS += -DCMAKE_BUILD_TYPE=Release

define LIBRETRO_MGBA_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(@D)/mgba_libretro.so \
		$(TARGET_DIR)/usr/lib/libretro/mgba_libretro.so
endef

$(eval $(cmake-package))