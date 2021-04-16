/*
 * Copyright (C) 2007 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <xf86drm.h>
#include <xf86drmMode.h>
#include <libdrm/drm_fourcc.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <errno.h>
#include <string.h> 
#include <string> 
#include <jpeglib.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <sys/time.h>

#include <linux/netlink.h>
#include <sys/socket.h>
#include <sys/syscall.h>

#include "drm_common.h"
#include "bootanimation.h"
using namespace std;

fd_set fds;
int max_fd = -1;
int uevent_fd = 0;
int mode_id=0;

static int drm_init(int drmFd) {
    int i, ret;

    ret = drmSetClientCap(drmFd, DRM_CLIENT_CAP_UNIVERSAL_PLANES, 1);
    if (ret) {
        printf( "Failed to set atomic cap %s \n", strerror(errno));
        return ret;
    }

    ret = drmSetClientCap(drmFd, DRM_CLIENT_CAP_ATOMIC, 1);
    if (ret) {
        printf( "Failed to set atomic cap %s \n", strerror(errno));
        return ret;
    }


    if (!drm_get_resources(drmFd))
        return -1;

    if (!drm_get_connector(drmFd))
        return -1;

    if (!drm_get_encoder(drmFd))
        return -1;
}

    static int
drmmode_getproperty(int drmFd, uint32_t obj_id, uint32_t obj_type, const char *prop_name)
{
    int property_id=-1;
    bool found = false;
    drmModeObjectPropertiesPtr props;

    props = drmModeObjectGetProperties(drmFd, obj_id, obj_type);
    for (int i = 0; !found && (size_t)i < props->count_props; ++i) {
        drmModePropertyPtr p = drmModeGetProperty(drmFd, props->props[i]);
        if (!strcmp(p->name, prop_name)) {
            property_id = p->prop_id;
            found = TRUE;
            break;
        }
        drmModeFreeProperty(p);
    }

    drmModeFreeObjectProperties(props);

    return property_id;
}

static int CreatePropertyBlob(void *data, size_t length,
        uint32_t *blob_id, int drm_fd) {
    struct drm_mode_create_blob create_blob;
    int ret=-1;
    memset(&create_blob, 0, sizeof(create_blob));
    create_blob.length = length;
    create_blob.data = (__u32)data;

    ret = drmIoctl(drm_fd, DRM_IOCTL_MODE_CREATEPROPBLOB, &create_blob);
    if (ret) {
        return ret;
    }
    *blob_id = create_blob.blob_id;
    return 0;
}

static int resolve_connectors(int drm_fd, drmModeRes *res, uint32_t *con_ids)
{
    drmModeConnector *connector;
    unsigned int i;
    uint32_t id;
    char *endp;

    for (i = 0; (int)i < res->count_connectors; i++)
    {
        drmModeConnectorPtr conn = drmModeGetConnector(
                drm_fd, res->connectors[i]);

        if (conn)
        {
            bool connected = conn->connection == DRM_MODE_CONNECTED;
            con_ids[i] = conn->connector_id;
            printf("con_ids[%d]=%d \n", i, con_ids[i]);
            drmModeFreeConnector(conn);
        }
    }

    return 0;
}

static void setMode(int drmFd, int modeid, drmModeConnectorPtr conn){
    uint32_t handles[4] = {0}, pitches[4] = {0}, offsets[4] = {0};
    unsigned int fb_id;
    struct armsoc_bo *bo;
    unsigned int i;
    unsigned int j;
    int ret, x;
    uint32_t num_cons;
    drmModeAtomicReq *req;
    uint32_t blob_id=0;
    int property_crtc_id,mode_property_id,active_property_id;
    drmModeCrtcPtr crtc;
    drmModeModeInfo *drm_mode = NULL;
    drmModeEncoder *drm_encoder  = NULL;
    drmModeRes *g_resources = g_drm_resources;
    uint32_t conn_id;

    num_cons = g_resources->count_connectors;

    if (conn == NULL) {
        return;
    }
    if (conn) {
        if (modeid < conn->count_modes)
            drm_mode = &conn->modes[modeid];
        else
            drm_mode = &conn->modes[0];
        if (g_resources->count_crtcs > 1) {
            if (conn->encoder_id == 0 && 
                    conn->connector_type == DRM_MODE_CONNECTOR_HDMIA)
                crtc = drmModeGetCrtc(drmFd, g_resources->crtcs[0]);
            else if(conn->encoder_id == 0)
                crtc = drmModeGetCrtc(drmFd, g_resources->crtcs[1]);
            else
                crtc = drmModeGetCrtc(drmFd, g_resources->crtcs[0]);
        } else {
            crtc = drmModeGetCrtc(drmFd, g_resources->crtcs[0]);;
        }

        req = drmModeAtomicAlloc();
#define DRM_ATOMIC_ADD_PROP(object_id, prop_id, value) \
        ret = drmModeAtomicAddProperty(req, object_id, prop_id, value); \
        printf("setMode object[%d] = %d\n", object_id, value); \
        if (ret < 0) \
        printf("Failed to add prop[%d] to [%d]", value, object_id);

        conn_id = conn->connector_id;

        ret = CreatePropertyBlob(drm_mode, sizeof(*drm_mode), &blob_id, drmFd);
        property_crtc_id = drmmode_getproperty(drmFd, conn_id, DRM_MODE_OBJECT_CONNECTOR, "CRTC_ID");
        DRM_ATOMIC_ADD_PROP(conn_id, property_crtc_id, crtc->crtc_id);
        mode_property_id = drmmode_getproperty(drmFd, crtc->crtc_id, DRM_MODE_OBJECT_CRTC, "MODE_ID");
        DRM_ATOMIC_ADD_PROP(crtc->crtc_id, mode_property_id, blob_id);
        active_property_id = drmmode_getproperty(drmFd, crtc->crtc_id, DRM_MODE_OBJECT_CRTC, "ACTIVE");
        DRM_ATOMIC_ADD_PROP(crtc->crtc_id, active_property_id, 1);
        ret = drmModeAtomicCommit(drmFd, req, DRM_MODE_ATOMIC_ALLOW_MODESET | DRM_MODE_PAGE_FLIP_EVENT, NULL);
        drmModeAtomicFree(req);
        if (crtc)
            drmModeFreeCrtc(crtc);

        drm_update(drmFd);
    }
}

static void updateModes(int fd)
{
    unsigned i;
    unsigned monitor_index = 0;
    bool isHdmiConnect=false;
    /* Enumerate all connectors. */
    for (i = 0; (int)i < g_drm_resources->count_connectors; i++)
    {
        drmModeConnectorPtr conn = drmModeGetConnector(
                fd, g_drm_resources->connectors[i]);

        if (conn)
        {
            bool connected = conn->connection == DRM_MODE_CONNECTED;
            if (connected && conn->count_modes > 0)
            {
                monitor_index++;
                if (conn->connector_type == DRM_MODE_CONNECTOR_HDMIA)
                    isHdmiConnect=true;
            }
            drmModeFreeConnector(conn);
        }
    }
    printf("hotplug: remove connector monitor_index=%d\n", monitor_index);
    if (monitor_index == 0) {
        vsync_control(false);
        drmModeAtomicReq *req;
        bool inuse=true;
        int ret;
        int property_crtc_id,mode_property_id,active_property_id;
        req = drmModeAtomicAlloc();

        for (i = 0; (int)i < g_drm_resources->count_connectors; i++)
        {
            drmModeConnectorPtr conn = drmModeGetConnector(
                    fd, g_drm_resources->connectors[i]);

            if (conn && conn->connection != DRM_MODE_CONNECTED)
            {
                property_crtc_id = drmmode_getproperty(fd, conn->connector_id, DRM_MODE_OBJECT_CONNECTOR, "CRTC_ID");
                DRM_ATOMIC_ADD_PROP(conn->connector_id, property_crtc_id, 0);
                drmModeFreeConnector(conn);
            }
        }
        printf("g_drm_encoder = NULL *************\n");
        for (int i = 0; i < g_drm_resources->count_crtcs; ++i) {
            mode_property_id = drmmode_getproperty(fd, g_drm_resources->crtcs[i], DRM_MODE_OBJECT_CRTC, "MODE_ID");
            DRM_ATOMIC_ADD_PROP(g_drm_resources->crtcs[i], mode_property_id, 0);
            active_property_id = drmmode_getproperty(fd, g_drm_resources->crtcs[i], DRM_MODE_OBJECT_CRTC, "ACTIVE");
            DRM_ATOMIC_ADD_PROP(g_drm_resources->crtcs[i], active_property_id, 0);
        }

        ret = drmModeAtomicCommit(fd, req, DRM_MODE_ATOMIC_ALLOW_MODESET, NULL);
        drmModeAtomicFree(req);
    }else {
        for (i = 0; (int)i < g_drm_resources->count_connectors; i++)
        {
            drmModeConnectorPtr conn = drmModeGetConnector(
                    fd, g_drm_resources->connectors[i]);
            if (conn == NULL)
                continue;

            bool connected = conn->connection == DRM_MODE_CONNECTED;
            if (isHdmiConnect=true)
            {
                if (connected && conn->count_modes > 0 && conn->connector_type == DRM_MODE_CONNECTOR_HDMIA)
                {
                    monitor_index++;
                    setMode(fd, mode_id, conn);
                    printf("[DRM]: HDMI Connector %d assigned to monitor index: #%u.\n", i, monitor_index);
                    break;
                }
            } else {
                if (connected && conn->count_modes > 0)
                {
                    monitor_index++;
                    setMode(fd, mode_id, conn);
                    printf("[DRM]: CVBS Connector %d assigned to monitor index: #%u.\n", i, monitor_index);
                }
            }
            drmModeFreeConnector(conn);
        }
        vsync_control(true);
    }
}

static void set_crtc_mode(int drmFd, int modeid)
{
    uint32_t handles[4] = {0}, pitches[4] = {0}, offsets[4] = {0};
    unsigned int fb_id;
    struct armsoc_bo *bo;
    unsigned int i;
    unsigned int j;
    int ret, x;
    uint32_t* con_ids;
    uint32_t num_cons;
    drmModeCrtcPtr crtc;
    drmModeModeInfo *drm_mode = NULL;
    drmModeEncoder *drm_encoder  = NULL;
    drmModeRes *g_resources = g_drm_resources;

    num_cons = g_resources->count_connectors;
    con_ids = (uint32_t*)calloc(num_cons, sizeof(*con_ids));
    resolve_connectors(drmFd, g_resources, con_ids);

    if (modeid < g_drm_connector->count_modes)
        drm_mode = &g_drm_connector->modes[modeid];
    else
        drm_mode = &g_drm_connector->modes[0];
    if (g_resources->count_crtcs > 1) {
        if (g_drm_connector->encoder_id == 0 && 
                g_drm_connector->connector_type == DRM_MODE_CONNECTOR_HDMIA)
            crtc = drmModeGetCrtc(drmFd, g_resources->crtcs[0]);
        else if(g_drm_connector->encoder_id == 0)
            crtc = drmModeGetCrtc(drmFd, g_resources->crtcs[1]);
        else
            crtc = drmModeGetCrtc(drmFd, g_resources->crtcs[0]);
    } else {
        crtc = drmModeGetCrtc(drmFd, g_resources->crtcs[0]);;
    }

    bo = bo_create(drmFd, DRM_FORMAT_ARGB8888, drm_mode->hdisplay,
            drm_mode->vdisplay);
    offsets[0] = 0;
    handles[0] = bo->handle;
    pitches[0] = bo->pitch;

    ret = drmModeAddFB2(drmFd, drm_mode->hdisplay, drm_mode->vdisplay,
            DRM_FORMAT_ARGB8888, handles, pitches, offsets, &fb_id, 0);
    if (ret) {
        fprintf(stderr, "failed to add fb (%ux%u): %s\n",
                drm_mode->hdisplay, drm_mode->vdisplay, strerror(errno));
        return;
    }

    ret = drmModeSetCrtc(drmFd, crtc->crtc_id, fb_id,
            0, 0, con_ids, num_cons,
            drm_mode);

    /* XXX: Actually check if this is needed */
    drmModeDirtyFB(drmFd, fb_id, NULL, 0);
    x += drm_mode->hdisplay;

    if (ret) {
        fprintf(stderr, "failed to set mode: %s\n", strerror(errno));
        return;
    }
}

void UEventHandler(int drm_fd) {
    char buffer[1024];
    int ret;

    struct timespec ts;
    uint64_t timestamp = 0;
    ret = clock_gettime(CLOCK_MONOTONIC, &ts);
    if (!ret)
        timestamp = ts.tv_sec * 1000 * 1000 * 1000 + ts.tv_nsec;
    else
        printf("Failed to get monotonic clock on hotplug %d", ret);

    while (true) {
        ret = read(uevent_fd, &buffer, sizeof(buffer));
        if (ret == 0) {
            return;
        } else if (ret < 0) {
            printf("Got error reading uevent %d", ret);
            return;
        }

        bool drm_event = false, hotplug_event = false;
        for (int i = 0; i < ret;) {
            char *event = buffer + i;
            if (strcmp(event, "DEVTYPE=drm_minor"))
                drm_event = true;
            else if (strcmp(event, "HOTPLUG=1"))
            {
                if (strncmp(buffer, "change@", 7) == 0)
                    hotplug_event = true;
                //else if (strncmp(buffer, "libudev", 7) == 0)
                //printf("hwc_uevent libudev HOTPLUG=1 buffer=%s pid=0x%x\n", buffer, syscall(SYS_gettid));
                printf("hwc_uevent detect HOTPLUG=1 buffer=%s hotplug_event=%d\n", buffer, hotplug_event);
            }

            i += strlen(event) + 1;
        }
        if (drm_event && hotplug_event) {
            updateModes(drm_fd);
        }
    }
}

void init(int drm_fd)
{
    struct sockaddr_nl addr;

    uevent_fd = socket(PF_NETLINK, SOCK_DGRAM, NETLINK_KOBJECT_UEVENT);
    memset(&addr, 0, sizeof(addr));
    addr.nl_family = AF_NETLINK;
    addr.nl_groups = 0xFFFFFFFF;
    int ret = bind(uevent_fd, (struct sockaddr *)&addr, sizeof(addr));

    FD_ZERO(&fds);
    FD_SET(drm_fd, &fds);
    FD_SET(uevent_fd, &fds);
    max_fd = (uevent_fd>drm_fd)?uevent_fd:drm_fd;
}

void* Routine(void* param) {
    int mDrmFd = drm_get_device();
    init(mDrmFd);
    while (true) {
        int ret;
        do {
            ret = select(max_fd + 1, &fds, NULL, NULL, NULL);
        } while (ret == -1 && errno == EINTR);

        if (FD_ISSET(mDrmFd, &fds)) {
            drmEventContext event_context = {
                .version = DRM_EVENT_CONTEXT_VERSION,
                .vblank_handler = NULL,
                .page_flip_handler = NULL};
            drmHandleEvent(mDrmFd, &event_context);
        }

        if (FD_ISSET(uevent_fd, &fds))
            UEventHandler(mDrmFd);
    }
}

int main(int argc, char** argv)
{
    int                     mThreadStatus;
    pthread_t				uevent_thread;
    int drm_fd = 0;

    int modeid=0;
    if (argc > 1)
        modeid = atoi(argv[1]);
    mode_id = modeid;
    printf("argc=%d modeid=%d\n", argc, modeid);
    drm_fd = drm_get_device();
    if (drm_fd < 0)
        printf("Failed to open dri 0 =%s\n", strerror(errno));
    drm_init(drm_fd);
    if (modeid <=0) {
        //mode_id = 1;
        mThreadStatus = pthread_create(&uevent_thread, NULL, Routine, &drm_fd);
        start_boot_thread(drm_fd);
        vsync_control(true);
    } else {
        updateModes(drm_fd);
    }
    while(1){
        usleep(200*1000);
    }
    drm_free();
    close(drm_fd);
    stop_boot_thread();
    if (pthread_join(uevent_thread, NULL) != 0) {
        printf("Couldn't cancel vsync thread \n");
    }

    return 0;
}
