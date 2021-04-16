################################################################################
#
# rubix
#
################################################################################

RUBIX_VERSION = 1.0.5
RUBIX_SOURCE = rubix-$(RUBIX_VERSION).tar.bz2
RUBIX_SITE = http://mirror.egtvedt.no/avr32linux.org/twiki/pub/Main/Rubix
RUBIX_LICENSE = Public Domain
RUBIX_LICENSE_FILES = LICENCE
RUBIX_DEPENDENCIES = xlib_libX11

RUBIX_MAKE_OPTS = \
	CC="$(TARGET_CC)" \
	XINC="-I$(STAGING_DIR)/usr/include/X11" \
	XLIB="-L$(STAGING_DIR)/usr/lib -lX11"

RUBIX_INSTALL_TARGET_OPTS = GAMESDIR=$(TARGET_DIR)/usr/games install

$(eval $(autotools-package))
