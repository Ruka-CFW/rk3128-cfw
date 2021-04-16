# add test tool for rockchip platform
# Author : Hans Yang <yhx@rock-chips.com>

ROCKCHIP_TEST_VERSION = 20201125
ROCKCHIP_TEST_SITE_METHOD = local
ROCKCHIP_TEST_SITE = $(TOPDIR)/package/rockchip/rockchip_test/src
ROCKCHIP_TEST_LICENSE = Apache V2.0
ROCKCHIP_TEST_LICENSE_FILES = NOTICE

ifeq ($(BR2_PACKAGE_RKNPU)$(BR2_PACKAGE_RKNN_DEMO),y)
define ROCKCHIP_TEST_INSTALL_NPU_TARGET_CMDS
	rm -rf ${TARGET_DIR}/rockchip_test/npu
	cp -rf $(@D)/npu_${ARCH}  ${TARGET_DIR}/rockchip_test/npu
endef
ROCKCHIP_TEST_POST_INSTALL_TARGET_HOOKS = ROCKCHIP_TEST_INSTALL_NPU_TARGET_CMDS
endif

define ROCKCHIP_TEST_INSTALL_TARGET_CMDS
	cp -rf  $(@D)/rockchip_test  ${TARGET_DIR}/
	cp -rf $(@D)/rockchip_test_${ARCH}/* ${TARGET_DIR}/rockchip_test/ || true
	$(INSTALL) -D -m 0755 $(@D)/rockchip_test/auto_reboot/S99_auto_reboot $(TARGET_DIR)/etc/init.d/
endef

$(eval $(generic-package))
