################################################################################
#
# elf2flt
#
################################################################################

ELF2FLT_VERSION = 6d80ab6c93409e796f85da404bde84b841231531
ELF2FLT_SITE = $(call github,uclinux-dev,elf2flt,$(ELF2FLT_VERSION))
ELF2FLT_LICENSE = GPL-2.0+
ELF2FLT_LICENSE_FILES = LICENSE.TXT

HOST_ELF2FLT_DEPENDENCIES = host-binutils host-zlib

# It is not exactly a host variant, but more a cross variant, which is
# why we pass a special --target option.
HOST_ELF2FLT_CONF_OPTS = \
	--with-bfd-include-dir=$(HOST_BINUTILS_DIR)/bfd/ \
	--with-binutils-include-dir=$(HOST_BINUTILS_DIR)/include/ \
	--with-libbfd=$(HOST_BINUTILS_DIR)/bfd/libbfd.a \
	--with-libiberty=$(HOST_BINUTILS_DIR)/libiberty/libiberty.a \
	--target=$(GNU_TARGET_NAME) \
	--disable-werror

HOST_ELF2FLT_LIBS = -lz

ifeq ($(BR2_GCC_ENABLE_LTO),y)
HOST_ELF2FLT_LIBS += -ldl
endif

HOST_ELF2FLT_CONF_ENV = LIBS="$(HOST_ELF2FLT_LIBS)"

$(eval $(host-autotools-package))
