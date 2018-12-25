//
//  stub.c
//  FFmpeg
//
//  Created by Chen Fang on 2018/12/25.
//  Copyright © 2018 Chen Fang. All rights reserved.
//

#include <FFmpeg.h>

#ifdef FFMPEG_HAS_avutil
void ffmpeg_avutil_stub_load() {
    // NOTHING
}
#endif

#ifdef FFMPEG_HAS_avcodec
void ffmpeg_avcodec_stub_load() {
    (void)avcodec_alloc_context3(NULL);
}
#endif

#ifdef FFMPEG_HAS_avformat
void ffmpeg_avformat_stub_load() {
    (void)avformat_open_input(NULL, NULL, NULL, NULL);
}
#endif

#ifdef FFMPEG_HAS_avfilter
void ffmpeg_avfilter_stub_load() {
    (void)avfilter_get_by_name(NULL);
}
#endif

#ifdef FFMPEG_HAS_swresample
void ffmpeg_swresample_stub_load() {
    (void)swr_init(NULL);
}
#endif

#ifdef FFMPEG_HAS_swscale
void ffmpeg_swscale_stub_load() {
    (void)sws_getContext(0, 0, AV_PIX_FMT_NONE,
                         0, 0, AV_PIX_FMT_NONE,
                         0, NULL, NULL, NULL);
}
#endif
