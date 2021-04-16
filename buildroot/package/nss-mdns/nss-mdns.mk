################################################################################
#
# nss-mdns
#
################################################################################

NSS_MDNS_VERSION = 0.10
NSS_MDNS_SITE = http://0pointer.de/lennart/projects/nss-mdns
NSS_MDNS_LICENSE = LGPL-2.1+
NSS_MDNS_LICENSE_FILES = LICENSE

define NSS_MDNS_INSTALL_CONFIG
	if [ ! -f "$(TARGET_DIR)/etc/nsswitch.conf" ]; then \
		$(INSTALL) -D -m 0644 package/glibc/nsswitch.conf $(TARGET_DIR)/etc/nsswitch.conf ; \
	fi
	sed -r -i -e 's/^(hosts:[[:space:]]+).*/\1files mdns4_minimal [NOTFOUND=return] dns mdns4/' \
		$(TARGET_DIR)/etc/nsswitch.conf
endef

NSS_MDNS_POST_INSTALL_TARGET_HOOKS += NSS_MDNS_INSTALL_CONFIG

$(eval $(autotools-package))
