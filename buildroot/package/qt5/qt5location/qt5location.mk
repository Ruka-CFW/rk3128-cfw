################################################################################
#
# qt5location
#
################################################################################

QT5LOCATION_VERSION = $(QT5_VERSION)
QT5LOCATION_SITE = $(QT5_SITE)
QT5LOCATION_SOURCE = qtlocation-$(QT5_SOURCE_TARBALL_PREFIX)-$(QT5LOCATION_VERSION).tar.xz
QT5LOCATION_INSTALL_STAGING = YES

ifeq ($(BR2_PACKAGE_QT5_VERSION_5_9),)
QT5LOCATION_LICENSE = GPL-2.0+ or LGPL-3.0, GPL-3.0 with exception(tools), GFDL-1.3 (docs)
QT5LOCATION_LICENSE_FILES = LICENSE.GPL2 LICENSE.GPL3 LICENSE.GPL3-EXCEPT LICENSE.LGPL3 LICENSE.FDL
else
QT5LOCATION_LICENSE = GPL-2.0 or GPL-3.0 or LGPL-2.1 with exception or LGPL-3.0, GFDL-1.3 (docs)
QT5LOCATION_LICENSE_FILES = LICENSE.GPLv2 LICENSE.GPLv3 LICENSE.GPL3-EXCEPT LICENSE.LGPLv3 LICENSE.FDL
endif

ifeq ($(BR2_PACKAGE_QT5DECLARATIVE),y)
QT5LOCATION_DEPENDENCIES += qt5declarative
endif

$(eval $(qmake-package))
