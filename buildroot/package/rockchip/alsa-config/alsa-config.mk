################################################################################
#
# Copy extra alsa configs to /usr/share/alsa/
#
################################################################################

ALSA_CONFIG_VERSION = 1.0
ALSA_CONFIG_SITE = $(TOPDIR)/../external/alsa-config
ALSA_CONFIG_SITE_METHOD = local

ALSA_CONFIG_LICENSE = Apache V2.0
ALSA_CONFIG_LICENSE_FILES = NOTICE

$(eval $(meson-package))
