################################################################################
#
# qt5
#
################################################################################

ifeq ($(BR2_PACKAGE_QT5_VERSION_5_15),y)
QT5_VERSION_MAJOR = 5.15
QT5_VERSION = $(QT5_VERSION_MAJOR).2
QT5_SOURCE_TARBALL_PREFIX = everywhere-src
else ifeq ($(BR2_PACKAGE_QT5_VERSION_5_14),y)
QT5_VERSION_MAJOR = 5.14
QT5_VERSION = $(QT5_VERSION_MAJOR).2
QT5_SOURCE_TARBALL_PREFIX = everywhere-src
else ifeq ($(BR2_PACKAGE_QT5_VERSION_5_12),y)
QT5_VERSION_MAJOR = 5.12
QT5_VERSION = $(QT5_VERSION_MAJOR).2
QT5_SOURCE_TARBALL_PREFIX = everywhere-src
else ifeq ($(BR2_PACKAGE_QT5_VERSION_5_9),y)
QT5_VERSION_MAJOR = 5.9
QT5_VERSION = $(QT5_VERSION_MAJOR).4
QT5_SOURCE_TARBALL_PREFIX = opensource-src
endif
QT5_SITE = https://download.qt.io/archive/qt/$(QT5_VERSION_MAJOR)/$(QT5_VERSION)/submodules

include $(sort $(wildcard package/qt5/*/*.mk))

# The file "qt.conf" can be used to override the hard-coded paths that are
# compiled into the Qt library. We need it to make "qmake" relocatable and
# tweak the per-package install pathes
define QT5_INSTALL_QT_CONF
	sed -e "s|@@HOST_DIR@@|$(HOST_DIR)|" -e "s|@@STAGING_DIR@@|$(STAGING_DIR)|" \
		$(QT5BASE_PKGDIR)/qt.conf.in > $(HOST_DIR)/bin/qt.conf
endef

ifeq ($(BR2_PER_PACKAGE_DIRECTORIES),y)
define QT5_QT_CONF_FIXUP
	$(QT5_INSTALL_QT_CONF)
endef
endif

# Variable for other Qt applications to use
QT5_QMAKE = $(HOST_DIR)/bin/qmake -spec devices/linux-buildroot-g++
