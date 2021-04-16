################################################################################
#
# rockit project
#
################################################################################

ROCKIT_SITE = $(TOPDIR)/../external/rockit

ROCKIT_SITE_METHOD = local

ROCKIT_INSTALL_STAGING = YES

ifeq ($(BR2_PACKAGE_MPP),y)
ROCKIT_DEPENDENCIES += mpp
endif

ifeq ($(BR2_PACKAGE_FFMPEG),y)
ROCKIT_DEPENDENCIES += ffmpeg
endif

ifeq ($(BR2_PACKAGE_CAMERA_ENGINE_RKAIQ), y)
ROCKIT_DEPENDENCIES += camera_engine_rkaiq
ROCKIT_CONF_OPTS += -DUSE_RKAIQ=ON
endif

ifeq ($(BR2_PACKAGE_AISERVER_USE_STASTERIA), y)
ROCKIT_CONF_OPTS += -DUSE_STASTERIA=ON
endif
$(eval $(cmake-package))
