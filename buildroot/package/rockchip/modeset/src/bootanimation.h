#ifndef BOOT_ANIMATION_H
#define BOOT_ANIMATION_H
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <xf86drm.h>
#include <xf86drmMode.h>
#include <libdrm/drm_fourcc.h>

#define BOOT_ANIMATION_CONFIG_FILE "/mnt/bootanimation/boot.conf"
#define JPEG_OUTPUT_BUF_CNT 6
#define MAX_OUTPUT_RSV_CNT 4
struct mdrm_mode_modeinfo {
    __u32 clock;
    __u16 hdisplay;
    __u16 hsync_start;
    __u16 hsync_end;
    __u16 htotal;
    __u16 hskew;
    __u16 vdisplay;
    __u16 vsync_start;
    __u16 vsync_end;
    __u16 vtotal;
    __u16 vscan;

    __u32 vrefresh;

    __u32 flags;
    __u32 type;
    char name[32];
};
struct plane_prop {
    int crtc_id;
    int fb_id;
    int src_x;
    int src_y;
    int src_w;
    int src_h;
    int crtc_x;
    int crtc_y;
    int crtc_w;
    int crtc_h;
};

typedef struct
{
    void * decoderHandle;
    char *outAddr;
    int phyAddr;
} HwJpegOutputBuf;

typedef struct
{
    struct armsoc_bo* bo;
	char mPath[128];
}SfJpegOutputBuf;

extern int start_boot_thread(int mDrmFd);
extern void stop_boot_thread();
extern int vsync_control(bool enabled);
extern int signale_thread();
extern struct armsoc_bo* bo_create_dumb(int fd, unsigned int width, unsigned int height, unsigned int bpp);
extern int bo_map(struct armsoc_bo *bo); 
extern struct armsoc_bo* bo_create(int fd, unsigned int format,
        unsigned int width, unsigned int height);
extern int bo_destroy(struct armsoc_bo *bo);
extern void bo_unmap(struct armsoc_bo *bo);
#endif
