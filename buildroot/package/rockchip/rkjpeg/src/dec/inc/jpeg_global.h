#ifndef _JPEG_GLOBAL_
#define _JPEG_GLOBAL_
#ifdef DRM_LINUX
#include "vpu_macro.h"
#else
#include "vpu_api.h"
#endif
#include "allocator_drm.h"

typedef struct tJPEG_FRAME
{
    RK_U32          FrameBusAddr[2];       //0: Y address; 1: UV address;
    RK_U32          FrameWidth;         //16X������
    RK_U32          FrameHeight;        //16X����߶�
    RK_U32          OutputWidth;        //��16X����
    RK_U32          OutputHeight;       //��16X����
    RK_U32          DisplayWidth;       //��ʾ���
    RK_U32          DisplayHeight;      //��ʾ�߶�
    RK_U32          ColorType;
    RK_U32          ErrorInfo;          //��֡�Ĵ�����Ϣ�����ظ�ϵͳ�������
    RK_U32	        employ_cnt;
    MppBufferInfo   jpegmem;
    struct tJPEG_FRAME *    next_frame;
    RK_U32          Res[4];
}JPEG_FRAME;
#endif /*_VPU_GLOBAL_*/
