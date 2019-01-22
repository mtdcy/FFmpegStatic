//
//  FFmpeg.h
//  FFmpeg
//
//  Created by Chen Fang on 2018/12/25.
//  Copyright © 2018 Chen Fang. All rights reserved.
//

#ifndef __FFMPEG_HEADERS__
#define __FFMPEG_HEADERS__

#include <sys/cdefs.h>

__BEGIN_DECLS

#include <FFmpeg/FFmpegConfiguration.h>

/** avutils headers */
#ifdef FFMPEG_HAS_avutil
#include <FFmpeg/libavutil/avutil.h>
#include <FFmpeg/libavutil/buffer.h>
#include <FFmpeg/libavutil/frame.h>
#include <FFmpeg/libavutil/version.h>
#include <FFmpeg/libavutil/hwcontext.h>
#include <FFmpeg/libavutil/pixfmt.h>
#include <FFmpeg/libavutil/pixdesc.h>
#include <FFmpeg/libavutil/pixelutils.h>
#endif

/** avcodec headers */
#ifdef FFMPEG_HAS_avcodec
#include <FFmpeg/libavcodec/version.h>
#include <FFmpeg/libavcodec/avcodec.h>
#ifdef __APPLE__
#include <FFmpeg/libavcodec/videotoolbox.h>
#endif
#endif

/** avformat headers */
#ifdef FFMPEG_HAS_avformat
#include <FFmpeg/libavformat/avformat.h>
#include <FFmpeg/libavformat/avio.h>
#include <FFmpeg/libavformat/version.h>
#endif

/** avfilter headers */
#ifdef FFMPEG_HAS_avfilter
#include <FFmpeg/libavfilter/avfilter.h>
#include <FFmpeg/libavfilter/version.h>
#endif

/** swresample headers */
#ifdef FFMPEG_HAS_swresample
#include <FFmpeg/libswresample/swresample.h>
#include <FFmpeg/libswresample/version.h>
#endif

/** swscale headers */
#ifdef FFMPEG_HAS_swscale
#include <FFmpeg/libswscale/swscale.h>
#include <FFmpeg/libswscale/version.h>
#endif

#ifdef FFMPEG_HAS_avdevice
#include <FFmpeg/libavdevice/avdevice.h>
#include <FFmpeg/libavdevice/version.h>
#endif

__END_DECLS

#endif
