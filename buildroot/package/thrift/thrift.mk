################################################################################
#
# thrift
#
################################################################################

THRIFT_VERSION = 0.9.2
THRIFT_SITE = http://www.us.apache.org/dist/thrift/$(THRIFT_VERSION)
THRIFT_DEPENDENCIES = host-autoconf-archive host-pkgconf host-thrift boost \
	libevent openssl zlib
THRIFT_INSTALL_STAGING = YES
HOST_THRIFT_DEPENDENCIES = host-autoconf-archive host-bison host-boost \
	host-flex host-libevent host-openssl host-pkgconf host-zlib

THRIFT_CONF_OPTS = --with-sysroot=$(STAGING_DIR) \
	--with-boost \
	--with-boost-libdir=$(STAGING_DIR)/usr/lib \
	--disable-tests \
	--disable-tutorial
HOST_THRIFT_CONF_OPTS = --with-sysroot=$(HOST_DIR) \
	--disable-tests \
	--disable-tutorial
THRIFT_AUTORECONF = YES
THRIFT_AUTORECONF_OPTS = -I $(HOST_DIR)/share/autoconf-archive
THRIFT_LICENSE = Apache-2.0
THRIFT_LICENSE_FILES = LICENSE

# relocation truncated to fit: R_68K_GOT16O
ifeq ($(BR2_m68k_cf),y)
THRIFT_CONF_ENV += CXXFLAGS="$(TARGET_CXXFLAGS) -mxgot"
endif

ifeq ($(BR2_STATIC_LIBS),y)
# openssl uses zlib, so we need to explicitly link with it when static
THRIFT_CONF_ENV += LIBS=-lz
endif

# Language selection
# The generator (host tool) works with all of them regardless
# This is just for the libraries / bindings
THRIFT_LANG_CONF_OPTS += --without-csharp --without-java --without-erlang \
	--without-python --without-perl --without-php --without-php_extension \
	--without-ruby --without-haskell --without-go --without-d \
	--without-qt4 --without-lua
HOST_THRIFT_CONF_OPTS += $(THRIFT_LANG_CONF_OPTS) --without-c_glib
THRIFT_CONF_OPTS += $(THRIFT_LANG_CONF_OPTS)

# C bindings
ifeq ($(BR2_PACKAGE_LIBGLIB2),y)
THRIFT_DEPENDENCIES += libglib2
else
THRIFT_CONF_OPTS += --without-c_glib
endif

# De-hardcode THRIFT for cross compiling
define THRIFT_TOOL_NO_HARDCODE
	for f in `find $(@D) -name Makefile.am -type f`; do \
		$(SED) "/^THRIFT =/d" $$f; \
	done
	$(SED) "s:top_builddir)/compiler/cpp/thrift:THRIFT):" $(@D)/tutorial/Makefile.am
endef

THRIFT_POST_PATCH_HOOKS += THRIFT_TOOL_NO_HARDCODE

define THRIFT_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) THRIFT=$(HOST_DIR)/bin/thrift -C $(@D)
endef

# Install runtime only
define THRIFT_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/lib DESTDIR=$(TARGET_DIR) install
endef

$(eval $(autotools-package))
$(eval $(host-autotools-package))

# to be used by other packages
THRIFT = $(HOST_DIR)/bin/thrift
