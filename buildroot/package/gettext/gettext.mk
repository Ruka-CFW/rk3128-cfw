################################################################################
#
# gettext
#
################################################################################

GETTEXT_VERSION = 0.19.8.1
GETTEXT_SITE = $(BR2_GNU_MIRROR)/gettext
GETTEXT_SOURCE = gettext-$(GETTEXT_VERSION).tar.xz
GETTEXT_INSTALL_STAGING = YES
GETTEXT_LICENSE = LGPL-2.1+ (libintl), GPL-3.0+ (the rest)
GETTEXT_LICENSE_FILES = COPYING gettext-runtime/intl/COPYING.LIB
# 0002-Update-after-gnulib-changed.patch
GETTEXT_AUTORECONF = YES
GETTEXT_DEPENDENCIES = $(if $(BR2_PACKAGE_LIBICONV),libiconv)

# Avoid using the bundled subset of libxml2
HOST_GETTEXT_DEPENDENCIES = host-libxml2

GETTEXT_CONF_OPTS += \
	--disable-libasprintf \
	--disable-acl \
	--disable-openmp \
	--disable-rpath \
	--disable-java \
	--disable-native-java \
	--disable-csharp \
	--disable-relocatable \
	--without-emacs

HOST_GETTEXT_CONF_OPTS = \
	--disable-libasprintf \
	--disable-acl \
	--disable-openmp \
	--disable-rpath \
	--disable-java \
	--disable-native-java \
	--disable-csharp \
	--disable-relocatable \
	--without-emacs

# Force the build of libintl, even if the C library provides a stub
# gettext implementation
ifeq ($(BR2_PACKAGE_GETTEXT_PROVIDES_LIBINTL),y)
GETTEXT_CONF_OPTS += --with-included-gettext
else
GETTEXT_CONF_OPTS += --without-included-gettext
endif

# For the target version, we only need the runtime, and for the host
# version, we only need the tools.
GETTEXT_SUBDIR = gettext-runtime
HOST_GETTEXT_SUBDIR = gettext-tools

# Disable the build of documentation and examples of gettext-tools,
# and the build of documentation and tests of gettext-runtime.
define HOST_GETTEXT_DISABLE_UNNEEDED
	$(SED) '/^SUBDIRS/s/ doc //;/^SUBDIRS/s/examples$$//' $(@D)/gettext-tools/Makefile.in
	$(SED) '/^SUBDIRS/s/ doc //;/^SUBDIRS/s/tests$$//' $(@D)/gettext-runtime/Makefile.in
endef

GETTEXT_POST_PATCH_HOOKS += HOST_GETTEXT_DISABLE_UNNEEDED
HOST_GETTEXT_POST_PATCH_HOOKS += HOST_GETTEXT_DISABLE_UNNEEDED

define GETTEXT_REMOVE_UNNEEDED
	$(RM) -rf $(TARGET_DIR)/usr/share/gettext/ABOUT-NLS
	rmdir --ignore-fail-on-non-empty $(TARGET_DIR)/usr/share/gettext
endef

GETTEXT_POST_INSTALL_TARGET_HOOKS += GETTEXT_REMOVE_UNNEEDED

# Force build with NLS support, otherwise libintl is not built
# This is needed because some packages (eg. libglib2) requires
# locales, but do not properly depend on BR2_ENABLE_LOCALE, and
# instead select BR2_PACKAGE_GETTEXT. Those packages need to be
# fixed before we can remove the following 3 lines... :-(
ifeq ($(BR2_ENABLE_LOCALE),)
GETTEXT_CONF_OPTS += --enable-nls
endif

# Disable interactive confirmation in host gettextize for package fixups
define HOST_GETTEXT_GETTEXTIZE_CONFIRMATION
	$(SED) '/read dummy/d' $(HOST_DIR)/bin/gettextize
endef
HOST_GETTEXT_POST_INSTALL_HOOKS += HOST_GETTEXT_GETTEXTIZE_CONFIRMATION

# autoreconf expects gettextize to install ABOUT-NLS, but it only gets
# installed by gettext-runtime which we don't build/install for the
# host, so do it manually
define HOST_GETTEXT_ADD_ABOUT_NLS
	$(INSTALL) -m 0644 $(@D)/$(HOST_GETTEXT_SUBDIR)/ABOUT-NLS \
		$(HOST_DIR)/share/gettext/ABOUT-NLS
endef

HOST_GETTEXT_POST_INSTALL_HOOKS += HOST_GETTEXT_ADD_ABOUT_NLS

GETTEXTIZE = $(HOST_CONFIGURE_OPTS) AUTOM4TE=$(HOST_DIR)/bin/autom4te $(HOST_DIR)/bin/gettextize -f

$(eval $(autotools-package))
$(eval $(host-autotools-package))
