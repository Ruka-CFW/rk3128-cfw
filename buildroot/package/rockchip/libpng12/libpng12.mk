################################################################################
#
# libpng
#
################################################################################

LIBPNG12_VERSION = 1.2.59
LIBPNG12_SERIES = 12
LIBPNG12_SOURCE = libpng-$(LIBPNG12_VERSION).tar.xz
LIBPNG12_SITE = http://downloads.sourceforge.net/project/libpng/libpng${LIBPNG12_SERIES}/$(LIBPNG12_VERSION)
LIBPNG12_LICENSE = Libpng
LIBPNG12_LICENSE_FILES = LICENSE
LIBPNG12_INSTALL_STAGING = YES
LIBPNG12_DEPENDENCIES = host-pkgconf zlib
HOST_LIBPNG12_DEPENDENCIES = host-pkgconf host-zlib
LIBPNG12_CONFIG_SCRIPTS = libpng$(LIBPNG12_SERIES)-config libpng-config

ifeq ($(BR2_ARM_CPU_HAS_NEON),y)
LIBPNG12_CONF_OPTS += --enable-arm-neon
else
LIBPNG12_CONF_OPTS += --disable-arm-neon
endif

ifeq ($(BR2_X86_CPU_HAS_SSE2),y)
LIBPNG12_CONF_OPTS += --enable-intel-sse
else
LIBPNG12_CONF_OPTS += --disable-intel-sse
endif

$(eval $(autotools-package))
$(eval $(host-autotools-package))
