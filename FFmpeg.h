//
//  .h
//  
//
//  Created by Chen Fang on 2018/12/25.
//  Copyright © 2018 Chen Fang. All rights reserved.
//

#ifndef __FFMPEG_HEADERS__
#define __FFMPEG_HEADERS__

#include "sys/cdefs.h"

// libavutil need this
#ifndef __STDC_CONSTANT_MACROS
#define __STDC_CONSTANT_MACROS
#endif
#ifndef __STDC_LIMIT_MACROS
#define __STDC_LIMIT_MACROS
#endif

__BEGIN_DECLS

#include "FFmpegConfiguration.h"

/** avutils headers */
#ifdef FFMPEG_HAS_avutil
#include "libavutil/avutil.h"
#include "libavutil/buffer.h"
#include "libavutil/frame.h"
#include "libavutil/version.h"
#include "libavutil/hwcontext.h"
#include "libavutil/pixfmt.h"
#include "libavutil/pixdesc.h"
#include "libavutil/pixelutils.h"
#endif

/** avcodec headers */
#ifdef FFMPEG_HAS_avcodec
#include "libavcodec/version.h"
#include "libavcodec/avcodec.h"
#ifdef __APPLE__
#include "libavcodec/videotoolbox.h"
#endif
#endif

/** avformat headers */
#ifdef FFMPEG_HAS_avformat
#include "libavformat/avformat.h"
#include "libavformat/avio.h"
#include "libavformat/version.h"
#endif

/** avfilter headers */
#ifdef FFMPEG_HAS_avfilter
#include "libavfilter/avfilter.h"
#include "libavfilter/version.h"
#endif

/** swresample headers */
#ifdef FFMPEG_HAS_swresample
#include "libswresample/swresample.h"
#include "libswresample/version.h"
#endif

/** swscale headers */
#ifdef FFMPEG_HAS_swscale
#include "libswscale/swscale.h"
#include "libswscale/version.h"
#endif

#ifdef FFMPEG_HAS_avdevice
#include "libavdevice/avdevice.h"
#include "libavdevice/version.h"
#endif

__END_DECLS

#endif
