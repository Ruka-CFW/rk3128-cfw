################################################################################
#
# tb(thunder boot)
#
################################################################################

THUNDERBOOT_VERSION = master
THUNDERBOOT_SITE_METHOD = local
THUNDERBOOT_SITE = $(TOPDIR)/package/rockchip/thunderboot

KERNEL_VERSION=`make -C $(TOPDIR)/../kernel kernelversion |grep -v make`
THUNDERBOOT_INSTALL_MODULES = $(call qstrip,$(BR2_THUNDERBOOT_INSTALL_MODULES))
THUNDERBOOT_ADB = $(call qstrip,$(BR2_THUNDERBOOT_USB_ADBD))
THUNDERBOOT_RNDIS = $(call qstrip,$(BR2_THUNDERBOOT_USB_RNDIS))
THUNDERBOOT_USB_CONFIG = $(TARGET_DIR)/etc/preinit.d/.usb_config
THUNDERBOOT_USB_MODULES = dwc3.ko,dwc3-rockchip-inno.ko,phy-rockchip-naneng-usb2.ko,dwc3-of-simple.ko
INSTALL_MODULES = $(THUNDERBOOT_INSTALL_MODULES)

define THUNDERBOOT_BUILD_CMDS
	make -C $(TOPDIR)/../kernel INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=${THUNDERBOOT_BUILDDIR} modules_install ARCH=${BR2_ARCH}
endef

ifeq ($(BR2_THUNDERBOOT_SIMPLIFY_USB),y)
define THUNDERBOOT_USB
	$(INSTALL) -D -m 755 $(@D)/S50tb_usbdevice $(TARGET_DIR)/etc/preinit.d/
	if test -e $(THUNDERBOOT_USB_CONFIG) ; then \
		rm $(THUNDERBOOT_USB_CONFIG) ; \
	fi
	touch $(THUNDERBOOT_USB_CONFIG)
endef
INSTALL_MODULES += $(THUNDERBOOT_USB_MODULES)
THUNDERBOOT_POST_INSTALL_TARGET_HOOKS += THUNDERBOOT_USB
endif

ifeq ($(BR2_THUNDERBOOT_ETH),y)
define THUNDERBOOT_ETH
	$(INSTALL) -D -m 755 $(@D)/S90tb_eth $(TARGET_DIR)/etc/preinit.d/
endef
THUNDERBOOT_ETH_MODULES = stmmac.ko,stmmac-platform.ko,dwmac-rockchip.ko
INSTALL_MODULES += $(THUNDERBOOT_ETH_MODULES)
THUNDERBOOT_POST_INSTALL_TARGET_HOOKS += THUNDERBOOT_ETH
endif

define THUNDERBOOT_INSTALL_TARGET_CMDS
	rm -rf $(TARGET_DIR)/oem $(TARGET_DIR)/userdata && mkdir -p $(TARGET_DIR)/oem $(TARGET_DIR)/userdata
	mkdir -p $(TARGET_DIR)/lib/modules/ $(TARGET_DIR)/etc/preinit.d/

	for module in `echo ${INSTALL_MODULES} | tr ',' '\n'`; do \
		find ${THUNDERBOOT_BUILDDIR}/lib/modules/${KERNEL_VERSION}/kernel -name $$module | xargs -i cp {} $(TARGET_DIR)/lib/modules/; \
	done
endef
THUNDERBOOT_POST_INSTALL_TARGET_HOOKS += THUNDERBOOT_INSTALL_TARGET_CMDS

ifeq ($(BR2_PACKAGE_THUNDERBOOT_BATIPC_LAUNCH),y)
define THUNDERBOOT_INSTALL_BATIPC_CMDS
	ln -rsf $(TARGET_DIR)/usr/share/mediaserver/$(call qstrip,$(BR2_PACKAGE_MEDIASERVE_CONFIG)) $(TARGET_DIR)/usr/share/mediaserver/tb.conf

	$(INSTALL) -D -m 755 $(@D)/S06tb_launch $(TARGET_DIR)/etc/preinit.d/
	$(INSTALL) -D -m 755 $(@D)/S07mountall $(TARGET_DIR)/etc/preinit.d/
	$(INSTALL) -D -m 755 $(@D)/tb_poweroff $(TARGET_DIR)/usr/bin/

	sed -i 's/CAMERA_FPS/$(BR2_PACKAGE_THUNDERBOOT_CAMERA_FPS)/g' $(TARGET_DIR)/etc/preinit.d/S06tb_launch
endef
THUNDERBOOT_POST_INSTALL_TARGET_HOOKS += THUNDERBOOT_INSTALL_BATIPC_CMDS
endif

ifeq ($(BR2_THUNDERBOOT_USB_ADBD),y)
define THUNDERBOOT_USB_ADBD
	if test ! `grep usb_adb_en $(THUNDERBOOT_USB_CONFIG)` ; then \
		echo usb_adb_en >> $(THUNDERBOOT_USB_CONFIG) ; \
	fi
endef
THUNDERBOOT_POST_INSTALL_TARGET_HOOKS += THUNDERBOOT_USB_ADBD
endif

ifeq ($(BR2_THUNDERBOOT_USB_RNDIS),y)
define THUNDERBOOT_USB_RNDIS
	if test ! `grep usb_rndis_en $(THUNDERBOOT_USB_CONFIG)` ; then \
		echo usb_rndis_en >> $(THUNDERBOOT_USB_CONFIG) ; \
	fi
endef
THUNDERBOOT_POST_INSTALL_TARGET_HOOKS += THUNDERBOOT_USB_RNDIS
endif

$(eval $(generic-package))
