################################################################################
#
# xapp_xman
#
################################################################################

XAPP_XMAN_VERSION = 1.1.4
XAPP_XMAN_SOURCE = xman-$(XAPP_XMAN_VERSION).tar.bz2
XAPP_XMAN_SITE = http://xorg.freedesktop.org/releases/individual/app
XAPP_XMAN_LICENSE = MIT
XAPP_XMAN_LICENSE_FILES = COPYING
XAPP_XMAN_DEPENDENCIES = xlib_libXaw
XAPP_XMAN_CONF_OPTS = --with-appdefaultdir=/usr/share/X11/app-defaults

XAPP_XMAN_CONF_ENV = \
	ac_cv_file__etc_man_conf=no \
	ac_cv_file__etc_man_config=no \
	ac_cv_file__etc_manpath_config=no \
	ac_cv_file__usr_share_misc_man_conf=no

$(eval $(autotools-package))
