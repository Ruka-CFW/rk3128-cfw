/*  RetroArch - A frontend for libretro.
 *  Copyright (c) 2011-2017 - Daniel De Matteis
 * 
 *  RetroArch is free software: you can redistribute it and/or modify it under the terms
 *  of the GNU General Public License as published by the Free Software Found-
 *  ation, either version 3 of the License, or (at your option) any later version.
 *
 *  RetroArch is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 *  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 *  PURPOSE.  See the GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along with RetroArch.
 *  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef __DRM_COMMON_H
#define __DRM_COMMON_H

#include <stdint.h>
#include <stddef.h>

#include <xf86drm.h>
#include <xf86drmMode.h>
#include <libdrm/drm_fourcc.h>
#include <fcntl.h>

#include <poll.h>
#include <stdbool.h>

//#include <boolean.h>

struct armsoc_device {
    int fd;
    bool alpha_supported;
};

struct armsoc_bo
{
    int fd;
    void *ptr;
    size_t size;
    size_t offset;
    size_t pitch;
    int width;
    int height;
    int format;
    unsigned handle;
    unsigned int fb_id;
    int dmabuf;
};

extern drmModeRes *g_drm_resources;
extern drmModeConnector *g_drm_connector;
extern drmModeEncoder *g_drm_encoder;

extern bool drm_get_encoder(int fd);
/* Restore the original CRTC. */
extern void drm_restore_crtc(void);
extern bool drm_get_resources(int fd);
extern void drm_update(int fd);
extern void drm_free(void);
extern bool drm_get_connector(int fd);
extern drmModeCrtcPtr drm_getcrtc(int fd, int* num);
extern int drm_get_device();

#endif
