################################################################################
#
# PPSSPP
#
################################################################################
# Version.: Commits on Feb 3, 2017
PPSSPP15_VERSION = 48934df6787cd9d693779ec1b0915a5c1ce02c72
PPSSPP15_SITE = https://github.com/hrydgard/ppsspp.git
PPSSPP15_SITE_METHOD=git
PPSSPP15_GIT_SUBMODULES=YES
PPSSPP15_LICENSE = GPLv2
PPSSPP15_DEPENDENCIES = sdl2 libzip ffmpeg

PPSSPP15_CONF_OPTS += -DUSE_FFMPEG=ON

PPSSPP15_CONF_OPTS += -DUSING_FBDEV=ON -DUSING_GLES2=ON
PPSSPP15_CONF_OPTS += -DUSING_EGL=OFF

PPSSPP15_CONF_OPTS += -DARM_NEON=ON
PPSSPP15_CONF_OPTS += -DARMV7=ON

PPSSPP15_CONF_CXXFLAGS += -DMESA_EGL_NO_X11_HEADERS=1 -DEGL_NO_X11=1
PPSSPP15_TARGET_CFLAGS += -DEGL_NO_X11=1 -DMESA_EGL_NO_X11_HEADERS=1
PPSSPP15_TARGET_CXXFLAGS += -DEGL_NO_X11=1 -DMESA_EGL_NO_X11_HEADERS=1



define PPSSPP15_UPDATE_INCLUDES
	sed -i "s+/opt/vc+$(STAGING_DIR)/usr+g" $(@D)/CMakeLists.txt
	sed -i 's/unknown/$(PPSSPP15_VERSION)/g' $(@D)/git-version.cmake
endef

PPSSPP15_PRE_CONFIGURE_HOOKS += PPSSPP15_UPDATE_INCLUDES

define PPSSPP15_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/PPSSPPSDL $(TARGET_DIR)/usr/bin/PPSSPP
	cp -R $(@D)/assets $(TARGET_DIR)/usr/bin
endef

$(eval $(cmake-package))
