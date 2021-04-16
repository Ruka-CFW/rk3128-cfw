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
#include <sys/mman.h>
#include <errno.h>
#include <string.h> 
#include <string> 
#include <jpeglib.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

#include <sys/time.h>
#include <unistd.h>

#include "libdrm_macros.h"
#include "drm_common.h"
#include "bootanimation.h"
#ifdef HW_JPEG
#include "pv_jpegdec_api.h"
#include "jpeg_global.h"
#include "vpu.h"
#include "vpu_api.h"
#endif
using namespace std;

SfJpegOutputBuf mBufSlotInfo[MAX_OUTPUT_RSV_CNT];
pthread_t thread_;
pthread_mutex_t lock_;
pthread_cond_t cond_;

int64_t last_timestamp_;
bool enabled_;
bool exit_;

int bufCnt;
int mImageCount;
char mBootAnimPath[128];
int mFps = 15; // default 15fps
void* mDecoder=NULL;
//static int mfps = 6000;
static int vsync_cnt=0;
static int last_win1_state=0;

static bool drmmode_getproperty(int drmFd, uint32_t obj_id, uint32_t obj_type, struct mdrm_mode_modeinfo* drm_mode)
{
    int property_id=-1;
    bool found = false;
    drmModeObjectPropertiesPtr props;

    props = drmModeObjectGetProperties(drmFd, obj_id, obj_type);
    for (int i = 0; !found && (size_t)i < props->count_props; ++i) {
        drmModePropertyBlobPtr blob;
        drmModePropertyPtr p = drmModeGetProperty(drmFd, props->props[i]);
        int value;

        if (!strcmp(p->name, "MODE_ID")) {
            struct mdrm_mode_modeinfo* mCurMode;
            found = true;
            if (!drm_property_type_is(p, DRM_MODE_PROP_BLOB)) {
                printf("%s:line=%d,is not blob",__FUNCTION__,__LINE__);
                drmModeFreeProperty(p);
                drmModeFreeObjectProperties(props);
                return false;
            }
            if (!p->count_blobs)
                value = props->prop_values[i];
            else
                value = p->blob_ids[0];
            blob = drmModeGetPropertyBlob(drmFd, value);
            if (!blob) {
                printf("%s:line=%d, blob is null\n",__FUNCTION__,__LINE__);
                drmModeFreeProperty(p);
                drmModeFreeObjectProperties(props);
                return false;
            }

            float vfresh;
            mCurMode = (struct mdrm_mode_modeinfo *)blob->data;
            memcpy(drm_mode, mCurMode, sizeof(*drm_mode));
            if (drm_mode->flags & DRM_MODE_FLAG_INTERLACE)
                vfresh = drm_mode->clock *2/ (float)(drm_mode->vtotal * drm_mode->htotal) * 1000.0f;
            else
                vfresh = drm_mode->clock / (float)(drm_mode->vtotal * drm_mode->htotal) * 1000.0f;
            //printf("drmmode_getproperty w=%d h=%d \n", drm_mode->hdisplay, drm_mode->vdisplay);
            drmModeFreePropertyBlob(blob);
        }
        drmModeFreeProperty(p);
    }
    drmModeFreeObjectProperties(props);
    return found;
}

static int drm_get_curActiveResolution(int drm_fd, int* width, int* height){
    struct mdrm_mode_modeinfo drm_mode;
    int ret=-1;

    if (g_drm_encoder != NULL) {
        ret = drmmode_getproperty(drm_fd, g_drm_encoder->crtc_id, DRM_MODE_OBJECT_CRTC, &drm_mode);
        if (ret == true) {
            *width = drm_mode.hdisplay;
            *height = drm_mode.vdisplay;
        } else {
            *width = 1280;
            *height = 720;
        }
    }
    return ret;
}

static bool drm_check_video(int drm_fd)
{
    bool is_win1_enable=false;;
    drmModePlaneResPtr plane_res;
    plane_res = drmModeGetPlaneResources(drm_fd);
    for (uint32_t i = 1; i < plane_res->count_planes; ++i) {
        bool foundPlane=false;
        drmModePlanePtr plane = drmModeGetPlane(drm_fd, plane_res->planes[i]);
        //printf("plane: crtc_id=%d fb_id=%d crtc_x=%d crtc_y=%d i =%d\n", plane->crtc_id, plane->fb_id, plane->crtc_x,plane->crtc_y,i);
        if (plane->fb_id > 0)
            is_win1_enable = true;
        drmModeFreePlane(plane);
    }
    if (plane_res)
        drmModeFreePlaneResources(plane_res);
    return is_win1_enable;
}

static int ctx_drm_display(int drm_fd, struct armsoc_bo* bo, int x, int y)
{
    drmModePlaneResPtr plane_res;
    drmModePlanePtr plane;
    drmModeResPtr res;
    drmModeCrtcPtr crtc = NULL;
    drmModeObjectPropertiesPtr props;
    drmModeAtomicReq *req;
    struct plane_prop plane_prop;
    int i, ret;
    int found_crtc = 0;
    int32_t flags = 0;
    uint32_t gem_handle;
    int crtc_w = 1280;
    int crtc_h = 720;

    if (g_drm_resources == NULL) {
        res = drmModeGetResources(drm_fd);
        if (!res) {
            printf("Failed to get resources: %s\n",
                    strerror(errno));
            return -ENODEV;
        }
    } else {
        res = g_drm_resources;
    }
    if (g_drm_encoder == NULL) {
        printf("g_drm_encoder nil\n");
        return 0;
    }
    /*
     * Found active crtc.
     */
    for (i = 0; i < res->count_crtcs; ++i) {
        uint32_t j;
        crtc = drmModeGetCrtc(drm_fd, res->crtcs[i]);
        if (!crtc) {
            printf("Could not get crtc %u: %s\n",
                    res->crtcs[i], strerror(errno));
            continue;
        }
        props = drmModeObjectGetProperties(drm_fd, crtc->crtc_id,
                DRM_MODE_OBJECT_CRTC);
        if (!props) {
            printf("failed to found props crtc[%d] %s\n",
                    crtc->crtc_id, strerror(errno));
            continue;
        }
        for (j = 0; j < props->count_props; j++) {
            drmModePropertyPtr prop;
            prop = drmModeGetProperty(drm_fd, props->props[j]);
            if (!strcmp(prop->name, "ACTIVE")) {
                if (props->prop_values[j]) {
                    //printf("found active crtc %d\n", crtc->crtc_id);
                    found_crtc = 1;
                    drmModeFreeProperty(prop);
                    break;
                }
            }
            drmModeFreeProperty(prop);
        }
        if (props) {
            drmModeFreeObjectProperties(props);
            props = NULL;
        }
        if (found_crtc)
            break;
        drmModeFreeCrtc(crtc);
        crtc = NULL;
    }

    if (!crtc) {
        if (props)
            drmModeFreeObjectProperties(props);
        printf("failed to find usable crtc props\n");
        return -ENODEV;
    }

    plane_res = drmModeGetPlaneResources(drm_fd);
    for (uint32_t i = 0; i < plane_res->count_planes; ++i) {
        bool foundPlane=false;
        plane = drmModeGetPlane(drm_fd, plane_res->planes[i]);
        //printf(" plan[%d].count_formats 0x%x : \n", i, plane->count_formats);
        for (uint32_t j = 0; j < plane->count_formats; j++) {
            //printf("  format %d : \n", plane->formats[j]);
            if (plane->formats[j] == bo->format) {
                //printf("found RGB layer ************\n");
                foundPlane = true;
                break;
            }
        }
        if (foundPlane)
            break;
        drmModeFreePlane(plane);
        plane = NULL;
    }

    //plane = drmModeGetPlane(drm_fd, plane_res->planes[1]);
    props = drmModeObjectGetProperties(drm_fd, plane->plane_id,
            DRM_MODE_OBJECT_PLANE);

    if (!props) {
        printf("failed to found props plane[%d] %s\n",
                plane->plane_id, strerror(errno));
        if (plane)
            drmModeFreePlane(plane);
        if (plane_res)
            drmModeFreePlaneResources(plane_res);
        if (props)
            drmModeFreeObjectProperties(props);
        if (crtc)
            drmModeFreeCrtc(crtc);
        return -ENODEV;
    }
    memset(&plane_prop, 0, sizeof(struct plane_prop));
    for (i = 0; i < props->count_props; i++) {
        drmModePropertyPtr prop;
        prop = drmModeGetProperty(drm_fd, props->props[i]);
        if (!strcmp(prop->name, "CRTC_ID"))
            plane_prop.crtc_id = prop->prop_id;
        else if (!strcmp(prop->name, "FB_ID"))
            plane_prop.fb_id = prop->prop_id;
        else if (!strcmp(prop->name, "SRC_X"))
            plane_prop.src_x = prop->prop_id;
        else if (!strcmp(prop->name, "SRC_Y"))
            plane_prop.src_y = prop->prop_id;
        else if (!strcmp(prop->name, "SRC_W"))
            plane_prop.src_w = prop->prop_id;
        else if (!strcmp(prop->name, "SRC_H"))
            plane_prop.src_h = prop->prop_id;
        else if (!strcmp(prop->name, "CRTC_X"))
            plane_prop.crtc_x = prop->prop_id;
        else if (!strcmp(prop->name, "CRTC_Y"))
            plane_prop.crtc_y = prop->prop_id;
        else if (!strcmp(prop->name, "CRTC_W"))
            plane_prop.crtc_w = prop->prop_id;
        else if (!strcmp(prop->name, "CRTC_H"))
            plane_prop.crtc_h = prop->prop_id;

        drmModeFreeProperty(prop);
        //xf86DrvMsg(-1, X_WARNING, "prop[%d] = %d\n", i, prop->prop_id);
    }
    ret = drm_get_curActiveResolution(drm_fd, &crtc_w, &crtc_h);
    if (ret<=0) {
        if (plane)
            drmModeFreePlane(plane);
        if (plane_res)
            drmModeFreePlaneResources(plane_res);
        if (props)
            drmModeFreeObjectProperties(props);
        if (crtc)
            drmModeFreeCrtc(crtc);
        return ret;
    }
    req = drmModeAtomicAlloc();
#define DRM_ATOMIC_ADD_PROP(object_id, prop_id, value) \
    ret = drmModeAtomicAddProperty(req, object_id, prop_id, value); \
    if (ret < 0) \
    printf("Failed to add prop[%d] to [%d]", value, object_id);
    DRM_ATOMIC_ADD_PROP(plane->plane_id, plane_prop.crtc_id, crtc->crtc_id);
    DRM_ATOMIC_ADD_PROP(plane->plane_id, plane_prop.fb_id, bo->fb_id);
    DRM_ATOMIC_ADD_PROP(plane->plane_id, plane_prop.src_x, x);
    DRM_ATOMIC_ADD_PROP(plane->plane_id, plane_prop.src_y, y);
    DRM_ATOMIC_ADD_PROP(plane->plane_id, plane_prop.src_w, bo->width << 16);
    DRM_ATOMIC_ADD_PROP(plane->plane_id, plane_prop.src_h, bo->height << 16);
    DRM_ATOMIC_ADD_PROP(plane->plane_id, plane_prop.crtc_x, 0);
    DRM_ATOMIC_ADD_PROP(plane->plane_id, plane_prop.crtc_y, 0);
    DRM_ATOMIC_ADD_PROP(plane->plane_id, plane_prop.crtc_w, crtc_w);
    DRM_ATOMIC_ADD_PROP(plane->plane_id, plane_prop.crtc_h, crtc_h);

    flags |= DRM_MODE_ATOMIC_ALLOW_MODESET;
#if 1
    ret = drmModeAtomicCommit(drm_fd, req, flags, NULL);
    if (ret)
        printf("atomic: couldn't commit new state: %s\n", strerror(errno));
    drmModeAtomicFree(req);
#else
    if (drmModeSetPlane(drm_fd, plane->plane_id,
                crtc->crtc_id, bo->fb_id, 0,
                0, 0, crtc_w, crtc_w,  0, 0, bo->width<<16, bo->height<<16)){
        printf("failed to enable plane: %s\n",
                strerror(errno));
    }
#endif

    if (plane)
        drmModeFreePlane(plane);
    if (plane_res)
        drmModeFreePlaneResources(plane_res);
    if (props)
        drmModeFreeObjectProperties(props);
    if (crtc)
        drmModeFreeCrtc(crtc);
    return ret;
}

struct armsoc_bo* bo_create_dumb(int fd, unsigned int width, unsigned int height, unsigned int bpp)
{
    struct drm_mode_create_dumb arg;
    struct armsoc_bo *bo;
    int ret;

    bo = (struct armsoc_bo *)calloc(1, sizeof(*bo));
    if (bo == NULL) {
        fprintf(stderr, "failed to allocate buffer object\n");
        return NULL;
    }

    memset(&arg, 0, sizeof(arg));
    arg.bpp = bpp;
    arg.width = width;
    arg.height = height;

    ret = drmIoctl(fd, DRM_IOCTL_MODE_CREATE_DUMB, &arg);
    if (ret) {
        fprintf(stderr, "failed to create dumb buffer: %s\n",
                strerror(errno));
        free(bo);
        return NULL;
    }

    bo->fd = fd;
    bo->handle = arg.handle;
    bo->size = arg.size;
    bo->pitch = arg.pitch;
    bo->width = width;
    bo->height = height;
    return bo;
}

int bo_map(struct armsoc_bo *bo)
{
    struct drm_mode_map_dumb arg;
    void *map;
    int ret;

    memset(&arg, 0, sizeof(arg));
    arg.handle = bo->handle;

    ret = drmIoctl(bo->fd, DRM_IOCTL_MODE_MAP_DUMB, &arg);
    if (ret)
        return ret;

    map = drm_mmap(0, bo->size, PROT_READ | PROT_WRITE, MAP_SHARED,
      bo->fd, arg.offset);
    //drmMap(bo->fd, arg.offset, bo->size, &map);
    if (map == MAP_FAILED)
        return -EINVAL;

    bo->ptr = map;
    return 0;
}

void bo_unmap(struct armsoc_bo *bo)
{
    if (!bo->ptr)
        return;
    //drm_munmap(bo->ptr, bo->size);
    drmUnmap(bo->ptr, bo->size);
    bo->ptr = NULL;
}

int bo_destroy(struct armsoc_bo *bo)
{
    struct drm_mode_destroy_dumb arg;
    struct drm_gem_close data;
    int ret;

    if (bo->fb_id) {
        drmModeRmFB (bo->fd, bo->fb_id);
        bo->fb_id = 0;
    }

    memset(&arg, 0, sizeof(arg));
    arg.handle = bo->handle;

    ret = drmIoctl(bo->fd, DRM_IOCTL_MODE_DESTROY_DUMB, &arg);
    if (ret)
        fprintf(stderr, "failed to destroy dumb buffer: %s fd=0x%x\n",
                strerror(errno), bo->fd);

    memset(&data, 0, sizeof(data));
    /*
       data.handle = bo->handle;
       ret = drmIoctl(bo->fd, DRM_IOCTL_GEM_CLOSE, &data);
       if (ret)
       return -errno;
    //free(bo);
     */
    return ret;
}

struct armsoc_bo* bo_create(int fd, unsigned int format,
        unsigned int width, unsigned int height)
{
    unsigned int virtual_height;
    struct armsoc_bo *bo;
    unsigned int bpp;
    int ret;

    switch (format) {
        case DRM_FORMAT_NV12:
        case DRM_FORMAT_NV21:
        case DRM_FORMAT_NV16:
        case DRM_FORMAT_NV61:
        case DRM_FORMAT_YUV420:
        case DRM_FORMAT_YVU420:
            bpp = 8;
            break;

        case DRM_FORMAT_ARGB4444:
        case DRM_FORMAT_XRGB4444:
        case DRM_FORMAT_ABGR4444:
        case DRM_FORMAT_XBGR4444:
        case DRM_FORMAT_RGBA4444:
        case DRM_FORMAT_RGBX4444:
        case DRM_FORMAT_BGRA4444:
        case DRM_FORMAT_BGRX4444:
        case DRM_FORMAT_ARGB1555:
        case DRM_FORMAT_XRGB1555:
        case DRM_FORMAT_ABGR1555:
        case DRM_FORMAT_XBGR1555:
        case DRM_FORMAT_RGBA5551:
        case DRM_FORMAT_RGBX5551:
        case DRM_FORMAT_BGRA5551:
        case DRM_FORMAT_BGRX5551:
        case DRM_FORMAT_RGB565:
        case DRM_FORMAT_BGR565:
        case DRM_FORMAT_UYVY:
        case DRM_FORMAT_VYUY:
        case DRM_FORMAT_YUYV:
        case DRM_FORMAT_YVYU:
            bpp = 16;
            break;

        case DRM_FORMAT_BGR888:
        case DRM_FORMAT_RGB888:
            bpp = 24;
            break;

        case DRM_FORMAT_ARGB8888:
        case DRM_FORMAT_XRGB8888:
        case DRM_FORMAT_ABGR8888:
        case DRM_FORMAT_XBGR8888:
        case DRM_FORMAT_RGBA8888:
        case DRM_FORMAT_RGBX8888:
        case DRM_FORMAT_BGRA8888:
        case DRM_FORMAT_BGRX8888:
        case DRM_FORMAT_ARGB2101010:
        case DRM_FORMAT_XRGB2101010:
        case DRM_FORMAT_ABGR2101010:
        case DRM_FORMAT_XBGR2101010:
        case DRM_FORMAT_RGBA1010102:
        case DRM_FORMAT_RGBX1010102:
        case DRM_FORMAT_BGRA1010102:
        case DRM_FORMAT_BGRX1010102:
            bpp = 32;
            break;

        default:
            fprintf(stderr, "unsupported format 0x%08x\n",  format);
            return NULL;
    }

    switch (format) {
        case DRM_FORMAT_NV12:
        case DRM_FORMAT_NV21:
        case DRM_FORMAT_YUV420:
        case DRM_FORMAT_YVU420:
            virtual_height = height * 3 / 2;
            break;

        case DRM_FORMAT_NV16:
        case DRM_FORMAT_NV61:
            virtual_height = height * 2;
            break;

        default:
            virtual_height = height;
            break;
    }

    bo = bo_create_dumb(fd, width, virtual_height, bpp);
    bo->format = format;
    if (!bo)
        return NULL;

    ret = bo_map(bo);
    if (ret) {
        fprintf(stderr, "failed to map buffer: %s\n",
                strerror(-errno));
        bo_destroy(bo);
        return NULL;
    }
    return bo;
}

static void jpeg_get_displayinfo(char* path, int* width, int* height)
{
    struct jpeg_decompress_struct cinfo;
    struct jpeg_error_mgr jerr;
    FILE* infile=NULL;
#ifdef TIME_DEBUG
    struct timeval start,end;
    gettimeofday(&start, NULL);
#endif

    if ((infile = fopen(path, "rb")) == NULL)
    {
        *width = 0;
        *height = 0;
        return;
    }
    cinfo.err = jpeg_std_error(&jerr);
    jpeg_create_decompress(&cinfo);
    jpeg_stdio_src(&cinfo, infile);
    jpeg_read_header(&cinfo, true);
    jpeg_calc_output_dimensions(&cinfo);
    *width = cinfo.output_width;
    *height = cinfo.output_height;
    jpeg_destroy_decompress (&cinfo);
#ifdef TIME_DEBUG
    gettimeofday(&end, NULL);
    printf("jpeg_get_displayinfo usetime=%d************4\n", (1000000 *(end.tv_sec - start.tv_sec) + (end.tv_usec-start.tv_usec))/1000);
#endif
    if (infile)
        fclose(infile);
}

static int jpeg_sf_decode(char* path, /*char* output*/struct armsoc_bo* bo)
{
    struct jpeg_decompress_struct cinfo;  
    struct jpeg_error_mgr jerr; 
    JSAMPARRAY lineBuf;
    int bytesPerPix;
    char* output = NULL;
#ifdef TIME_DEBUG
    struct timeval start,end;
    gettimeofday(&start, NULL);
#endif
    if (!bo)
        return -1;
    output = (char *)bo->ptr;

    cinfo.err = jpeg_std_error(&jerr);
    jpeg_create_decompress(&cinfo);
    FILE* infile, *outfile;
    int outSize=0;

    if ((infile = fopen(path, "rb")) == NULL)
    {
        perror("fopen fail");
        return 0;
    }
    jpeg_stdio_src(&cinfo, infile);
    jpeg_read_header(&cinfo, true);
    //cinfo.out_color_space = JCS_YCbCr;
    //cinfo.raw_data_out = true;
    jpeg_start_decompress(&cinfo);
#if 0
    printf("cinfo.image_width=%d cinfo.image_height=%d cinfo.jpeg_color_space=%d output-%p\n", 
            cinfo.image_width, cinfo.image_height, cinfo.jpeg_color_space, output);
    printf("cinfo.output_width=%d cinfo.output_height=%d cinfo.bytesPerPix=%d\n", 
            cinfo.output_width, cinfo.output_height, cinfo.output_components);
#endif
    outSize = cinfo.output_width * cinfo.output_height*3;
    bytesPerPix = cinfo.output_components;
    if(output == NULL)
    {
        jpeg_finish_decompress(&cinfo);
        jpeg_destroy_decompress(&cinfo);
        fclose(infile);
        return -2;
    }

    if (bo->size < outSize || bo->width < cinfo.output_width || bo->height < cinfo.output_height) {
        printf("%s: jpeg reslution(%dx%d) not match fb(%dx%d)\n",
	       __func__,
	       cinfo.output_width,
	       cinfo.output_height,
	       bo->width,
	       bo->height);

        jpeg_finish_decompress(&cinfo);
        jpeg_destroy_decompress(&cinfo);
        fclose(infile);
        return -1;
    }

    lineBuf = cinfo.mem->alloc_sarray ((j_common_ptr) &cinfo, JPOOL_IMAGE, (cinfo.output_width * bytesPerPix), 1);
    if (3 == bytesPerPix) {
        int x, y;
        char *line_fb = NULL;
        for (y = 0; y < cinfo.output_height; ++y) {
            jpeg_read_scanlines (&cinfo, lineBuf, 1);
#if !defined(MODESET_SWAP_RB)
            memcpy ((output + y * /*cinfo.output_width * 3*/bo->pitch),lineBuf[0],3 * cinfo.output_width);
#else
            line_fb = output + y * bo->pitch;
            for (x = 0; x < cinfo.output_width; ++x) {
                line_fb[x * 3 + 2] = lineBuf[0][x * 3 + 0];
                line_fb[x * 3 + 1] = lineBuf[0][x * 3 + 1];
                line_fb[x * 3 + 0] = lineBuf[0][x * 3 + 2];
            }
#endif
        }
    } else if (1 == bytesPerPix) {
        unsigned int col;
        int lineOffset = (cinfo.output_width * 3);
        int lineBufIndex;
        int x ;
        int y;

        for (y = 0; y < cinfo.output_height; ++y) {
            jpeg_read_scanlines (&cinfo, lineBuf, 1);

            lineBufIndex = 0;
            for (x = 0; x < lineOffset; ++x) {
                col = lineBuf[0][lineBufIndex];

                output[(lineOffset * y) + x] = col;
                ++x;
                output[(lineOffset * y) + x] = col;
                ++x;
                output[(lineOffset * y) + x] = col;

                ++lineBufIndex;
            }   
        }
    } else {
        printf ("Error: the number of color channels is %d.	This program only handles 1 or 3\n", bytesPerPix);
        return -1;
    }

    jpeg_finish_decompress (&cinfo);
    jpeg_destroy_decompress (&cinfo);
    fclose (infile);
#ifdef TIME_DEBUG
    gettimeofday(&end, NULL);
    printf("jpeg_sf_decode usetime=%d************4\n", (1000000 *(end.tv_sec - start.tv_sec) + (end.tv_usec-start.tv_usec))/1000);
#endif
    return 0;
}

void bootAnimation(int mDrmFd)
{
    int drm_fd = mDrmFd;
    int mFrameNum = 0;

    int pathSize = 128;
    char* picPath = (char*)calloc(1, pathSize);
    int displayWidth=0,displayHeight=0;
    uint32_t handles[4] = {0}, pitches[4] = {0}, offsets[4] = {0};
    for (int j=0;j<mImageCount;j++) {
        memset(picPath, 0, pathSize);
        displayWidth=displayHeight=0;
        sprintf(picPath, "%s/%d.jpg",mBootAnimPath,j);
        if (access(picPath, R_OK) != 0)
            sprintf(picPath, "%s/%d.jpeg",mBootAnimPath,j);
        if (access(picPath, R_OK) != 0) {
            printf("%s: can't access file %s \n", __func__, picPath);
            continue;
        }
        jpeg_get_displayinfo(picPath, &displayWidth, &displayHeight);

	printf("picPath: %s \n", picPath);

        if (displayWidth !=0 && displayHeight != 0) {
            struct armsoc_bo* bo=NULL;
            int slot=MAX_OUTPUT_RSV_CNT-1;
            bool found=false;

            if (mBufSlotInfo[slot].bo && mBufSlotInfo[slot].bo->fd != 0 && mBufSlotInfo[slot].bo->ptr != NULL) {
                bo_unmap(mBufSlotInfo[slot].bo);
                bo_destroy(mBufSlotInfo[slot].bo);
                free(mBufSlotInfo[slot].bo);
                printf("free: mSfJpegBufInfo[0].mPath %s \n", mBufSlotInfo[slot].mPath);
                mBufSlotInfo[slot].bo = NULL;			
                memset(mBufSlotInfo[slot].mPath, 0, sizeof(mBufSlotInfo[slot].mPath));
            }
            bo = bo_create(drm_fd, DRM_FORMAT_RGB888, displayWidth, displayHeight);
            if (bo == NULL) {
                printf( "failed to bo_create fb: %s\n", strerror(errno));
                return;
            }
            jpeg_sf_decode(picPath, /*(char*)bo->ptr*/bo);
            offsets[0] = 0;
            handles[0] = bo->handle;
            pitches[0] = bo->pitch;
            if (drmModeAddFB2(drm_fd, bo->width, bo->height, DRM_FORMAT_RGB888,
                        handles, pitches, offsets, &bo->fb_id, 0)) {
                printf( "failed to add fb: %s\n", strerror(errno));
                continue;
            }
            ctx_drm_display(drm_fd, bo, 0, 0);
            usleep(1000000 / mFps);
            mBufSlotInfo[0].bo = bo;
            sprintf(mBufSlotInfo[0].mPath, "%s", picPath);
            for (int tmp=MAX_OUTPUT_RSV_CNT-1;tmp>0;tmp--) {
                mBufSlotInfo[tmp].bo = mBufSlotInfo[tmp-1].bo;
                memcpy(mBufSlotInfo[tmp].mPath, mBufSlotInfo[tmp-1].mPath, strlen(mBufSlotInfo[tmp-1].mPath));
            }
            memset(mBufSlotInfo[0].mPath, 0, sizeof(mBufSlotInfo[0].mPath));
            mBufSlotInfo[0].bo = NULL;

        }
    }
    if (picPath) {
        free(picPath);
        picPath = NULL;
    }
}

static const int64_t kBillion = 1000000000LL;
static const int64_t kOneSecondNs = 1 * 1000 * 1000 * 1000;

int64_t GetPhasedVSync(int64_t frame_ns, int64_t current) {
    if (last_timestamp_ < 0)
        return current + frame_ns;

    return frame_ns * ((current - last_timestamp_) / frame_ns + 1) +
        last_timestamp_;
}

int SyntheticWaitVBlank(int64_t *timestamp) {
    struct timespec vsync;
    int ret = clock_gettime(CLOCK_MONOTONIC, &vsync);

    float refresh = 60.0f;  // Default to 60Hz refresh rate

    int64_t phased_timestamp = GetPhasedVSync(
            kOneSecondNs / refresh, vsync.tv_sec * kOneSecondNs + vsync.tv_nsec);
    vsync.tv_sec = phased_timestamp / kOneSecondNs;
    vsync.tv_nsec = phased_timestamp - (vsync.tv_sec * kOneSecondNs);
    do {
        ret = clock_nanosleep(CLOCK_MONOTONIC, TIMER_ABSTIME, &vsync, NULL);
    } while (ret == -1 && errno == EINTR);
    if (ret)
        return ret;

    *timestamp = (int64_t)vsync.tv_sec * kOneSecondNs + (int64_t)vsync.tv_nsec;
    return 0;
}

static struct timeval cur,last;
void Routine() 
{
    last = cur;
    int mDrmFd = drm_get_device();
    int ret = pthread_mutex_lock(&lock_);
    if (ret) {
        printf("Failed to lock worker %d \n", ret);
        return;
    }

    if (!enabled_) {
        printf("vsync: pthread_cond_wait\n");
        ret = ret = pthread_cond_wait(&cond_, &lock_);
        if (ret == -EINTR) {
            return;
        }
    }

    bool enabled = enabled_;

    ret = pthread_mutex_unlock(&lock_);
    if (ret) {
        printf("Failed to unlock worker %d \n", ret);
    }

    if (!enabled)
        return;
    int64_t timestamp;
    drmModeCrtcPtr crtc = NULL;
    int pipe=0;
    if (g_drm_connector)
        crtc = drm_getcrtc(mDrmFd, &pipe);
    if (!crtc) {
        ret = SyntheticWaitVBlank(&timestamp);
        if (ret)
            return;
    } else {
        uint32_t high_crtc = (pipe << DRM_VBLANK_HIGH_CRTC_SHIFT);

        drmVBlank vblank;
        memset(&vblank, 0, sizeof(vblank));
        vblank.request.type = (drmVBlankSeqType)(
                DRM_VBLANK_RELATIVE | (high_crtc & DRM_VBLANK_HIGH_CRTC_MASK));
        vblank.request.sequence = 1;

        ret = drmWaitVBlank(mDrmFd, &vblank);
        if (ret == -EINTR) {
            return;
        } else if (ret) {
            ret = SyntheticWaitVBlank(&timestamp);
            if (ret)
                return;
        } else {
            timestamp = (int64_t)vblank.reply.tval_sec * kOneSecondNs +
                (int64_t)vblank.reply.tval_usec * 1000;
        }
    }
    if (crtc)
        drmModeFreeCrtc(crtc);
    gettimeofday(&cur, NULL);
    usleep(10*1000);
    bool mCur_win1_state = 0;
    mCur_win1_state = drm_check_video(mDrmFd);
    //printf("Routine %d %d,usetime=%d************4\n", mCur_win1_state, vsync_cnt, (1000000 *(cur.tv_sec - last.tv_sec) + (cur.tv_usec-last.tv_usec))/1000);
    if (!mCur_win1_state &&  vsync_cnt == 0) {
        bootAnimation(mDrmFd);
        //if (vsync_cnt == mfps)
            //vsync_cnt = 0;
    }
	last_win1_state = mCur_win1_state;
    vsync_cnt ++;
}

void* vsyncThread(void* param)
{
    while (true) {
        int ret =  pthread_mutex_lock(&lock_);
        if (ret) {
            printf("Failed to lock %s thread %d\n", __func__, ret);
            continue;
        }

        bool exit = exit_;

        ret = pthread_mutex_unlock(&lock_);
        if (ret) {
            printf("Failed to unlock %s thread %d\n",  __func__, ret);
            break;
        }
        if (exit)
            break;
        Routine();
    }
    return 0;
}

int signale_locked(bool exit)
{
    if (exit)
        exit_ = exit;
    int ret = pthread_cond_signal(&cond_);
    if (ret)
        printf("Failed to signal condition  thread %d\n", ret);
    return ret;
}

int vsync_control(bool enabled)
{
    int ret;
    pthread_mutex_lock(&lock_);
    enabled_ = enabled;
    ret = signale_locked(false);
    //drm_update(drm_get_device());
    vsync_cnt = 0;
    printf("vsync_control: enable=%d exit=%d\n", enabled_, exit_);
    if (ret)
        printf("Failed to signal condition  thread %d\n", ret);
    pthread_mutex_unlock(&lock_);
    return ret;
}

void stop_boot_thread()
{
    for (int i=0;i<MAX_OUTPUT_RSV_CNT;i++) {
        if (mBufSlotInfo[i].bo->fd != 0 && mBufSlotInfo[i].bo->ptr != NULL) {
            printf("release drm res:i=%d fd=0x%x fb_id=0x%x ptr=%p addr=%p\n", i,
                    mBufSlotInfo[i].bo->fd, mBufSlotInfo[i].bo->fb_id, mBufSlotInfo[i].bo->ptr, mBufSlotInfo[i].bo);
            bo_unmap(mBufSlotInfo[i].bo);
            bo_destroy((mBufSlotInfo[i].bo));
            mBufSlotInfo[i].bo = NULL;
        }
    }

    pthread_mutex_lock(&lock_);
    exit_ = true;
    pthread_mutex_unlock(&lock_);
    int ret = pthread_cond_signal(&cond_);
    if (ret) {
        printf("Failed to signal condition  thread %d\n", ret);
        return;
    }
    if (pthread_join(thread_, NULL) != 0) {
        printf("Couldn't cancel vsync thread \n");
    }
    pthread_cond_destroy(&cond_);
    pthread_mutex_destroy(&lock_);
}

int start_boot_thread(int mDrmFd)
{
    FILE* cfg_file = fopen(BOOT_ANIMATION_CONFIG_FILE, "rb");
    pthread_condattr_t cond_attr;
    pthread_condattr_init(&cond_attr);
    pthread_condattr_setclock(&cond_attr, CLOCK_MONOTONIC);
    int ret = pthread_cond_init(&cond_, &cond_attr);

    exit_ = false;
    enabled_ = false;
    if (ret) {
        printf("Failed to int thread %s condition %d\n", __func__, ret);
        if (cfg_file)
            fclose(cfg_file);
        return ret;
    }

    ret = pthread_mutex_init(&lock_, NULL);
    if (ret) {
        printf("Failed to init thread  lock %d\n", ret);
        pthread_cond_destroy(&cond_);
        if (cfg_file)
            fclose(cfg_file);
        return ret;
    }

    bufCnt = JPEG_OUTPUT_BUF_CNT;
    mImageCount = 0;

    if (cfg_file) {
        char imageCnt[32];
        char path[128];
        char fps[32];
        if (!feof(cfg_file)) {
            fgets(imageCnt,32,cfg_file);
            fgets(path,128,cfg_file);
            fgets(fps,32,cfg_file);
        }
        sscanf(imageCnt, "cnt=%d", &mImageCount);
        sscanf(path, "path=%s", mBootAnimPath);
        sscanf(fps, "fps=%d", &mFps);
        printf("cfg:  mImageCount=%d mBootAnimPath=%s mFps %d\n", mImageCount, mBootAnimPath, mFps);
        fclose(cfg_file);
        if (mImageCount <= 0)
            mImageCount = 4;
    } else {
        mImageCount = 4;
        char* tmp = "/media/bootanimation";
        sprintf(mBootAnimPath, "%s", tmp);
    }
    printf("start_boot_thread: mDrmFd = %d\n", mDrmFd);
    ret = pthread_create(&thread_, NULL, vsyncThread, &mDrmFd);
    if (ret) {
        printf("Could not create thread  %d\n", ret);
        pthread_mutex_destroy(&lock_);
        pthread_cond_destroy(&cond_);
        return ret;
    }
    return 0;
}
