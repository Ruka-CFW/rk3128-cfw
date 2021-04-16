#include "drm_common.h"
#include <unistd.h>
#include <string.h>
#include <string>
#include <stdio.h>

#define MAX(x, y) (((x) > (y)) ? (x) : (y))
drmModeRes *g_drm_resources    = NULL;
drmModeConnector *g_drm_connector     = NULL;
drmModeModeInfo *g_drm_mode           = NULL;
drmModeEncoder *g_drm_encoder  = NULL;
int g_drm_fd = 0;

int drm_get_device()
{
    if (g_drm_fd <=0)
        g_drm_fd = open("/dev/dri/card0", O_RDWR);
    return g_drm_fd;
}

bool drm_get_resources(int fd)
{
    g_drm_resources = drmModeGetResources(fd);
    if (!g_drm_resources)
    {
        printf("[DRM]: Couldn't get device resources.\n");
        return false;
    }

    return true;
}

bool drm_get_connector(int fd)
{
    unsigned i;
    unsigned monitor_index = 0;
    bool isHdmiConnect=false;
    /* Enumerate all connectors. */

    printf("[DRM]: Found %d connectors.\n", g_drm_resources->count_connectors);
    for (i = 0; (int)i < g_drm_resources->count_connectors; i++)
    {
        drmModeConnectorPtr conn = drmModeGetConnector(
                fd, g_drm_resources->connectors[i]);

        if (conn)
        {
            bool connected = conn->connection == DRM_MODE_CONNECTED;
            printf("[DRM]: Connector %d connected: %s\n", i, connected ? "yes" : "no");
            printf("[DRM]: Connector %d has %d modes.\n", i, conn->count_modes);
            if (connected && conn->count_modes > 0 && conn->connector_type == DRM_MODE_CONNECTOR_HDMIA)
            {
                monitor_index++;
                isHdmiConnect=true;
                printf("[DRM]: HDMI Connector %d assigned to monitor index: #%u.\n", i, monitor_index);
                break;
            }
            drmModeFreeConnector(conn);
        }
    }

    monitor_index = 0;
    if (g_drm_connector != NULL)
        drmModeFreeConnector(g_drm_connector);
    printf("drm_get_connector: g_drm_connector=%p 11111\n", g_drm_connector);
    for (i = 0; (int)i < g_drm_resources->count_connectors; i++)
    {
        g_drm_connector = drmModeGetConnector(fd,
                g_drm_resources->connectors[i]);

        if (!g_drm_connector)
            continue;
        if (isHdmiConnect == true) {
            if (g_drm_connector->count_modes > 0 &&
                    g_drm_connector->connector_type == DRM_MODE_CONNECTOR_HDMIA)
            {
                monitor_index++;
                break;
            }
        } else {
            if (g_drm_connector->connection == DRM_MODE_CONNECTED
                    && g_drm_connector->count_modes > 0)
            {
                monitor_index++;
                break;
            }
        }
        drmModeFreeConnector(g_drm_connector);
        g_drm_connector = NULL;
    }

    if (!g_drm_connector)
    {
        printf("[DRM]: Couldn't get device connector.\n");
        return false;
    } else {
        for (i = 0; (int)i < g_drm_connector->count_modes; i++)
        {
            printf("[DRM]: Mode %d: (%s) %d x %d, %u Hz\n",
                    i,
                    g_drm_connector->modes[i].name,
                    g_drm_connector->modes[i].hdisplay,
                    g_drm_connector->modes[i].vdisplay,
                    g_drm_connector->modes[i].vrefresh);
        }
    }
    return true;
}

bool drm_get_encoder(int fd)
{
    unsigned i;

    if (g_drm_encoder != NULL)
        drmModeFreeEncoder(g_drm_encoder);
    for (i = 0; (int)i < g_drm_resources->count_encoders; i++)
    {
        g_drm_encoder = drmModeGetEncoder(fd, g_drm_resources->encoders[i]);

        if (!g_drm_encoder)
            continue;

        printf("g_drm_encoder->encoder_id=%d g_drm_connector->encoder_id=%d\n", g_drm_encoder->encoder_id, g_drm_connector->encoder_id);
        if (g_drm_connector && g_drm_encoder->encoder_id == g_drm_connector->encoder_id)
            break;

        drmModeFreeEncoder(g_drm_encoder);
        g_drm_encoder = NULL;
    }

    if (!g_drm_encoder)
    {
        printf("[DRM]: Couldn't find DRM encoder.\n");
        return false;
    }
    return true;
}

void drm_update(int fd)
{
    if (!drm_get_connector(fd))
        return;

    if (!drm_get_encoder(fd))
        return;
}

drmModeCrtcPtr drm_getcrtc(int fd, int* num)
{
    drmModeCrtcPtr mcrtc = NULL;
    if (g_drm_encoder != NULL) {
        for (int i = 0; i < g_drm_resources->count_crtcs; ++i) {
            if (g_drm_resources->crtcs[i] == g_drm_encoder->crtc_id) {
                mcrtc = drmModeGetCrtc(fd, g_drm_resources->crtcs[i]);
                *num = i;
                break;
            }
        }
    }
    return mcrtc;
}

void drm_free(void)
{
    if (g_drm_encoder)
        drmModeFreeEncoder(g_drm_encoder);
    if (g_drm_connector)
        drmModeFreeConnector(g_drm_connector);
    if (g_drm_resources)
        drmModeFreeResources(g_drm_resources);

    g_drm_encoder      = NULL;
    g_drm_connector    = NULL;
    g_drm_resources    = NULL;
}
