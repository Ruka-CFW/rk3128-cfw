################################################################################
#
# qt5serialport
#
################################################################################

QT5SERIALPORT_VERSION = $(QT5_VERSION)
QT5SERIALPORT_SITE = $(QT5_SITE)
QT5SERIALPORT_SOURCE = qtserialport-$(QT5_SOURCE_TARBALL_PREFIX)-$(QT5SERIALPORT_VERSION).tar.xz
QT5SERIALPORT_INSTALL_STAGING = YES

ifeq ($(BR2_PACKAGE_QT5_VERSION_5_9),)
QT5SERIALPORT_LICENSE = GPL-2.0+ or LGPL-3.0, GPL-3.0 with exception(tools), GFDL-1.3 (docs)
QT5SERIALPORT_LICENSE_FILES = LICENSE.GPL2 LICENSE.GPL3 LICENSE.GPL3-EXCEPT LICENSE.LGPL3 LICENSE.FDL
else
QT5SERIALPORT_LICENSE = GPL-2.0+ or LGPL-3.0, GPL-3.0 with exception(tools), GFDL-1.3 (docs)
QT5SERIALPORT_LICENSE_FILES = LICENSE.GPLv2 LICENSE.GPLv3 LICENSE.GPL3-EXCEPT LICENSE.LGPLv3 LICENSE.FDL
endif

$(eval $(qmake-package))
