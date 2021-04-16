################################################################################
#
# qt5wayland
#
################################################################################

QT5WAYLAND_VERSION = $(QT5_VERSION)
QT5WAYLAND_SITE = $(QT5_SITE)
QT5WAYLAND_SOURCE = qtwayland-$(QT5_SOURCE_TARBALL_PREFIX)-$(QT5WAYLAND_VERSION).tar.xz
QT5WAYLAND_DEPENDENCIES = wayland
QT5WAYLAND_INSTALL_STAGING = YES

ifeq ($(BR2_PACKAGE_QT5DECLARATIVE_QUICK),y)
QT5WAYLAND_DEPENDENCIES += qt5declarative
endif

ifeq ($(BR2_PACKAGE_LIBXKBCOMMON),y)
QT5WAYLAND_DEPENDENCIES += libxkbcommon
endif

ifeq ($(BR2_PACKAGE_QT5_VERSION_5_9),)
QT5WAYLAND_LICENSE = GPL-2.0+ or LGPL-3.0, GPL-3.0 with exception(tools), GFDL-1.3 (docs)
QT5WAYLAND_LICENSE_FILES = LICENSE.GPL2 LICENSE.GPL3 LICENSE.GPL3-EXCEPT LICENSE.LGPL3 LICENSE.FDL
else
QT5WAYLAND_LICENSE = GPL-3.0 or LGPL-2.1 with exception or LGPL-3.0, GFDL-1.3 (docs)
QT5WAYLAND_LICENSE_FILES = LICENSE.GPLv3 LICENSE.LGPLv21 LGPL_EXCEPTION.txt LICENSE.LGPLv3 LICENSE.FDL
endif

ifeq ($(BR2_PACKAGE_QT5WAYLAND_COMPOSITOR),y)
QT5WAYLAND_CONF_OPTS += CONFIG+=wayland-compositor
endif

define QT5WAYLAND_FORCE_XDG_SHELL_V6
	cd $(TARGET_DIR)/usr/lib/qt/plugins/wayland-shell-integration/ && \
		ls | grep -v v6 | xargs rm -rf
endef
QT5WAYLAND_POST_INSTALL_TARGET_HOOKS += QT5WAYLAND_FORCE_XDG_SHELL_V6

$(eval $(qmake-package))
