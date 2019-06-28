//
//  stub.c
//  FFmpeg
//
//  Created by Chen Fang on 2018/12/25.
//  Copyright © 2018 Chen Fang. All rights reserved.
//

#include <FFmpeg.h>

#ifdef HAS_libavutil
void ffmpeg_avutil_stub_load() {
    // NOTHING
}
#endif

#ifdef HAS_libavcodec
void ffmpeg_avcodec_stub_load() {
    (void)avcodec_alloc_context3(NULL);
    (void)avcodec_open2(NULL, NULL, NULL);
    (void)avcodec_close(NULL);
}
#endif

#ifdef HAS_libavformat
void ffmpeg_avformat_stub_load() {
    (void)avformat_open_input(NULL, NULL, NULL, NULL);
    (void)avformat_close_input(NULL);
}
#endif

#ifdef HAS_libavfilter
void ffmpeg_avfilter_stub_load() {
    (void)avfilter_get_by_name(NULL);
}
#endif

#ifdef HAS_libswresample
void ffmpeg_swresample_stub_load() {
    (void)swr_init(NULL);
}
#endif

#ifdef HAS_libswscale
void ffmpeg_swscale_stub_load() {
    (void)sws_getContext(0, 0, AV_PIX_FMT_NONE,
                         0, 0, AV_PIX_FMT_NONE,
                         0, NULL, NULL, NULL);
}
#endif

#ifdef HAS_libavdevice
void ffmpeg_avdevice_stub_load() {
    (void)avdevice_list_devices(NULL, NULL);
}
#endif
