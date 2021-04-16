################################################################################
#
# bluez5_utils
#
################################################################################

BLUEZ5_UTILS_VERSION = 5.50
BLUEZ5_UTILS_SOURCE = bluez-$(BLUEZ5_UTILS_VERSION).tar.xz
BLUEZ5_UTILS_SITE = $(BR2_KERNEL_MIRROR)/linux/bluetooth
BLUEZ5_UTILS_INSTALL_STAGING = YES
BLUEZ5_UTILS_DEPENDENCIES = dbus libglib2
BLUEZ5_UTILS_LICENSE = GPLv2+, LGPLv2.1+
BLUEZ5_UTILS_LICENSE_FILES = COPYING COPYING.LIB

BLUEZ5_UTILS_CONF_ENV = \
	LIBS=-lpthread

BLUEZ5_UTILS_CONF_OPTS = 	\
	--enable-tools 		\
	--enable-library 	\
	--disable-cups		\
	--enable-deprecated

ifeq ($(BR2_PACKAGE_DUERCLIENTSDK),y)
        BLUEZ5_UTILS_MAKE_OPTS = \
		CFLAGS+=" -DDUEROS=$(BR2_PACKAGE_DUERCLIENTSDK)"
endif

ifeq ($(BR2_PACKAGE_BLUEZ5_UTILS_OBEX),y)
BLUEZ5_UTILS_CONF_OPTS += --enable-obex
BLUEZ5_UTILS_DEPENDENCIES += libical
else
BLUEZ5_UTILS_CONF_OPTS += --disable-obex
endif

ifeq ($(BR2_PACKAGE_BLUEZ5_UTILS_CLIENT),y)
BLUEZ5_UTILS_CONF_OPTS += --enable-client
BLUEZ5_UTILS_DEPENDENCIES += readline
else
BLUEZ5_UTILS_CONF_OPTS += --disable-client
endif

# experimental plugins
ifeq ($(BR2_PACKAGE_BLUEZ5_UTILS_EXPERIMENTAL),y)
BLUEZ5_UTILS_CONF_OPTS += --enable-experimental
else
BLUEZ5_UTILS_CONF_OPTS += --disable-experimental
endif

# enable sixaxis plugin
ifeq ($(BR2_PACKAGE_BLUEZ5_PLUGINS_SIXAXIS),y)
BLUEZ5_UTILS_CONF_OPTS += --enable-sixaxis
else
BLUEZ5_UTILS_CONF_OPTS += --disable-sixaxis
endif

# install gatttool (For some reason upstream choose not to do it by default)
ifeq ($(BR2_PACKAGE_BLUEZ5_UTILS_GATTTOOL),y)
define BLUEZ5_UTILS_INSTALL_GATTTOOL
	$(INSTALL) -D -m 0755 $(@D)/attrib/gatttool $(TARGET_DIR)/usr/bin/gatttool
endef
BLUEZ5_UTILS_POST_INSTALL_TARGET_HOOKS += BLUEZ5_UTILS_INSTALL_GATTTOOL
endif

# enable test
ifeq ($(BR2_PACKAGE_BLUEZ5_UTILS_TEST),y)
BLUEZ5_UTILS_CONF_OPTS += --enable-test
else
BLUEZ5_UTILS_CONF_OPTS += --disable-test
endif

# use udev if available
ifeq ($(BR2_PACKAGE_HAS_UDEV),y)
BLUEZ5_UTILS_CONF_OPTS += --enable-udev
BLUEZ5_UTILS_DEPENDENCIES += udev
else
BLUEZ5_UTILS_CONF_OPTS += --disable-udev
endif

# integrate with systemd if available
ifeq ($(BR2_PACKAGE_SYSTEMD),y)
BLUEZ5_UTILS_CONF_OPTS += --enable-systemd
BLUEZ5_UTILS_DEPENDENCIES += systemd
else
BLUEZ5_UTILS_CONF_OPTS += --disable-systemd
endif

ifeq ($(BR2_PACKAGE_RK3036_ECHO),y)
BLUEZ5_UTILS_CONF_OPTS += --localstatedir=/data/cfg
endif

ifeq ($(BR2_PACKAGE_ALEXACLIENTSDK),y)
BLUEZ5_UTILS_CONF_OPTS += --localstatedir=/data/cfg
endif

ifeq ($(BR2_PACKAGE_RK3308),y)
BLUEZ5_UTILS_CONF_OPTS += --localstatedir=/data/cfg
endif


define BLUEZ5_UTILS_INSTALL_INIT_SYSTEMD
	mkdir -p $(TARGET_DIR)/etc/systemd/system/bluetooth.target.wants
	ln -fs ../../../../usr/lib/systemd/system/bluetooth.service \
		$(TARGET_DIR)/etc/systemd/system/bluetooth.target.wants/bluetooth.service
	ln -fs ../../../../usr/lib/systemd/system/bluetooth.service \
		$(TARGET_DIR)/etc/systemd/system/dbus-org.bluez.service
endef

define BLUEZ5_UTILS_POST_INSTALL_TARGET_HOOK1
	install -C $($(PKG)_BUILDDIR)tools/gatt-service $(TARGET_DIR)/usr/bin
        install -C $($(PKG)_BUILDDIR)tools/hciconfig $(TARGET_DIR)/usr/bin
        install -C $($(PKG)_BUILDDIR)tools/hcitool $(TARGET_DIR)/usr/bin
        install -C package/bluez5_utils/bluez5_utils_wifi_config.sh $(TARGET_DIR)/usr/bin/
endef

BLUEZ5_UTILS_POST_INSTALL_TARGET_HOOKS += BLUEZ5_UTILS_POST_INSTALL_TARGET_HOOK1

$(eval $(autotools-package))
