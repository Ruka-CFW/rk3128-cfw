################################################################################
#
# libuio
#
################################################################################

# v0.2.7
LIBUIO_VERSION = 940861de278cb794bf9d775b76a4d1d4f9108607
LIBUIO_SITE = $(call github,Linutronix,libuio,$(LIBUIO_VERSION))
LIBUIO_LICENSE = LGPL-2.1 (library), GPL-2.0 (programs)
LIBUIO_LICENSE_FILES = COPYING
LIBUIO_CONF_OPTS = --with-glib=no --without-werror
LIBUIO_DEPENDENCIES = $(TARGET_NLS_DEPENDENCIES)
LIBUIO_LIBS = $(TARGET_NLS_LIBS)
LIBUIO_INSTALL_STAGING = YES

# Fetched from github, no pre-generated configure script provided
LIBUIO_GETTEXTIZE = YES
LIBUIO_AUTORECONF = YES

# Avoid build issue when makeinfo is missing
LIBUIO_CONF_ENV += MAKEINFO=true

ifeq ($(BR2_PACKAGE_ARGP_STANDALONE),y)
LIBUIO_DEPENDENCIES += argp-standalone
LIBUIO_LIBS += -largp
endif

LIBUIO_CONF_ENV += LIBS="$(LIBUIO_LIBS)"

$(eval $(autotools-package))
