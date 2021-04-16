################################################################################
#
# docker-engine
#
################################################################################

DOCKER_ENGINE_VERSION = v17.05.0-ce
DOCKER_ENGINE_COMMIT = 89658bed64c2a8fe05a978e5b87dbec409d57a0f
DOCKER_ENGINE_SITE = $(call github,docker,docker,$(DOCKER_ENGINE_VERSION))

DOCKER_ENGINE_LICENSE = Apache-2.0
DOCKER_ENGINE_LICENSE_FILES = LICENSE

DOCKER_ENGINE_DEPENDENCIES = host-go host-pkgconf

DOCKER_ENGINE_GOPATH = "$(@D)/gopath"
DOCKER_ENGINE_MAKE_ENV = $(HOST_GO_TARGET_ENV) \
	CGO_ENABLED=1 \
	CGO_NO_EMULATION=1 \
	GOBIN="$(@D)/bin" \
	GOPATH="$(DOCKER_ENGINE_GOPATH)" \
	PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" \
	$(TARGET_MAKE_ENV)

DOCKER_ENGINE_GLDFLAGS = \
	-X main.GitCommit=$(DOCKER_ENGINE_VERSION) \
	-X main.Version=$(DOCKER_ENGINE_VERSION)

ifeq ($(BR2_STATIC_LIBS),y)
DOCKER_ENGINE_GLDFLAGS += -extldflags '-static'
else
ifeq ($(BR2_PACKAGE_DOCKER_ENGINE_STATIC_CLIENT),y)
DOCKER_ENGINE_GLDFLAGS_DOCKER += -extldflags '-static'
endif
endif

DOCKER_ENGINE_BUILD_TAGS = cgo exclude_graphdriver_zfs autogen
DOCKER_ENGINE_BUILD_TARGETS = docker

ifeq ($(BR2_PACKAGE_LIBSECCOMP),y)
DOCKER_ENGINE_BUILD_TAGS += seccomp
DOCKER_ENGINE_DEPENDENCIES += libseccomp
endif

ifeq ($(BR2_INIT_SYSTEMD),y)
DOCKER_ENGINE_BUILD_TAGS += journald
DOCKER_ENGINE_DEPENDENCIES += systemd
endif

ifeq ($(BR2_PACKAGE_DOCKER_ENGINE_DAEMON),y)
DOCKER_ENGINE_BUILD_TAGS += daemon
DOCKER_ENGINE_BUILD_TARGETS += dockerd
endif

ifeq ($(BR2_PACKAGE_DOCKER_ENGINE_EXPERIMENTAL),y)
DOCKER_ENGINE_BUILD_TAGS += experimental
endif

ifeq ($(BR2_PACKAGE_DOCKER_ENGINE_DRIVER_BTRFS),y)
DOCKER_ENGINE_DEPENDENCIES += btrfs-progs
else
DOCKER_ENGINE_BUILD_TAGS += exclude_graphdriver_btrfs
endif

ifeq ($(BR2_PACKAGE_DOCKER_ENGINE_DRIVER_DEVICEMAPPER),y)
DOCKER_ENGINE_DEPENDENCIES += lvm2
else
DOCKER_ENGINE_BUILD_TAGS += exclude_graphdriver_devicemapper
endif

ifeq ($(BR2_PACKAGE_DOCKER_ENGINE_DRIVER_VFS),y)
DOCKER_ENGINE_DEPENDENCIES += gvfs
else
DOCKER_ENGINE_BUILD_TAGS += exclude_graphdriver_vfs
endif

define DOCKER_ENGINE_CONFIGURE_CMDS
	mkdir -p $(DOCKER_ENGINE_GOPATH)/src/github.com/docker
	ln -fs $(@D) $(DOCKER_ENGINE_GOPATH)/src/github.com/docker/docker
	cd $(@D) && \
		GITCOMMIT="$$(echo $(DOCKER_ENGINE_COMMIT) | head -c7)" \
		BUILDTIME="$$(date)" \
		VERSION="$(patsubst v%,%,$(DOCKER_ENGINE_VERSION))" \
		PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" $(TARGET_MAKE_ENV) \
		bash ./hack/make/.go-autogen
endef

ifeq ($(BR2_PACKAGE_DOCKER_ENGINE_DAEMON),y)

define DOCKER_ENGINE_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 0644 $(@D)/contrib/init/systemd/docker.service \
		$(TARGET_DIR)/usr/lib/systemd/system/docker.service
	$(INSTALL) -D -m 0644 $(@D)/contrib/init/systemd/docker.socket \
		$(TARGET_DIR)/usr/lib/systemd/system/docker.socket
	mkdir -p $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/
	ln -fs ../../../../usr/lib/systemd/system/docker.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/docker.service
endef

define DOCKER_ENGINE_USERS
	- - docker -1 * - - - Docker Application Container Framework
endef

endif

define DOCKER_ENGINE_BUILD_CMDS
	$(foreach target,$(DOCKER_ENGINE_BUILD_TARGETS), \
		cd $(@D)/gopath/src/github.com/docker/docker; \
		$(DOCKER_ENGINE_MAKE_ENV) \
		$(HOST_DIR)/bin/go build -v \
			-o $(@D)/bin/$(target) \
			-tags "$(DOCKER_ENGINE_BUILD_TAGS)" \
			-ldflags "$(DOCKER_ENGINE_GLDFLAGS) $(DOCKER_ENGINE_GLDFLAGS_$(call UPPERCASE,$(target)))" \
			github.com/docker/docker/cmd/$(target)
	)
endef

define DOCKER_ENGINE_INSTALL_TARGET_CMDS
	$(foreach target,$(DOCKER_ENGINE_BUILD_TARGETS), \
		$(INSTALL) -D -m 0755 $(@D)/bin/$(target) $(TARGET_DIR)/usr/bin/$(target)
	)
endef

$(eval $(generic-package))
