#!/bin/bash 
cd `dirname $0`
source cbox.sh

# config 
# Note: 
# 1. for release, it's better to build a huge bundle. but for project use, huge bundle takes too much resources
HUGE=1
BUILD_DEP=1
GPL=0
ENCODER=0

# common codecs
DEMUXERS="aac,ac3,amr,ape,apng,aptx,asf,avi,eac3,flac,flv,gif,gsm,hls,m4v,matroska,mjpeg,mov,mp3,mpegps,mpegts,ogg,vc1,wav"
MUXERS="mov,mp3,mp4,flac,matroska,matroska_audio,ogg,wav"
A_DECODERS="aac,aac_fixed,aac_latm,ac3,ac3_fixed,alac,amrnb,amrwb,ape,aptx,aptx_hd,cook,dca,eac3,flac,g729,gsm,gsm_ms,mp1,mp1float,mp2,mp2float,mp3,mp3float,mp3adu,mp3adufloat,mp3on4,mp3on4float,als,opus,sbc,vorbis,wavpack,wmalossless,wmapro,wmav1,wmav2,wmavoice"
V_DECODERS="cavs,apng,flv,h261,h263,h263i,h263p,h264,hevc,jpeg2000,jpegls,mjpeg,mjpegb,mpeg1video,mpeg2video,mpegvideo,mpeg4,msmpeg4v1,msmpeg4v2,msmpeg4,png,rv10,rv20,rv30,rv40,vc1,vc1image,vp8,vp9,wmv1,wmv2,wmv3,wmv3image"
S_DECODERS="ssa,ass,dvbsub,dvdsub,mov_text,realtext,stl,srt"
A_ENCODERS=""
V_ENCODERS=""
S_ENCODERS=""

# workspace 
WS=`pwd`

# download packages
PKG=$WS/packages
mkdir -p $WS/packages
./download.sh || exit 1

# setup env
PREFIX=$WS/prebuilts
info "PREFIX: $PREFIX"
mkdir -p $WS/build/
cd $WS/build 

if [ $BUILD_DEP -eq 1 ]; then 
# zlib - zlib license 
ZLIB_ARGS="--prefix=$PREFIX"
tar -xf $WS/packages/zlib-1.2.11.tar.gz  &&
cd zlib-1.2.11  &&
./configure $ZLIB_ARGS && 
make install 
cd -

# lzma - in the public domain
XZ_ARGS="--prefix=$PREFIX --disable-debug --disable-dependency-tracking --disable-silent-rules"
tar -xf $WS/packages/xz-5.2.4.tar.bz2  &&
cd xz-5.2.4  &&
./configure $XZ_ARGS && 
make install
cd -

# libiconv - LGPL
LIBICONV_ARGS="--prefix=$PREFIX --disable-dependency-tracking --disable-debug --enable-extra-encodings --enable-static"
tar -xf $WS/packages/libiconv-1.15.tar.gz &&
cd libiconv-1.15  &&
./configure $LIBICONV_ARGS && 
make install
cd -

fi  # BUILD_DEP

# FFmpeg - GPL or LGPL
FFMPEG_ARGS="--prefix=$PREFIX --extra-ldflags=\"-L$PREFIX/lib\" --extra-cflags=\"-I$PREFIX/include\" --enable-shared --enable-static --enable-rpath --enable-pthreads --enable-hardcoded-tables --cc=clang --host-cflags= --host-ldflags= --enable-opencl --enable-videotoolbox"
if [ $HUGE -eq 1 ]; then 
    FFMPEG_ARGS+=" --enable-decoders --enable-encoders --enable-demuxers --enable-muxers"
else
    FFMPEG_ARGS+=" --disable-decoders --disable-encoders --disable-demuxers --disable-muxers"

    FFMPEG_ARGS+=" --enable-decoder=$A_DECODERS,$V_DECODERS,$S_DECODERS"

    if [ $ENCODER -eq 1 ]; then
        FFMPEG_ARGS+=" --enable-encoder=$A_ENCODERS,$V_ENCODERS,$S_ENCODERS"
    fi

    FFMPEG_ARGS+=" --enable-demuxer=$DEMUXERS"
    FFMPEG_ARGS+=" --enable-muxer=$MUXERS"
fi
info "ARGS: $FFMPEG_ARGS"

tar -xf $WS/packages/ffmpeg-4.1.tar.bz2 &&
cd ffmpeg-4.1 &&
./configure $FFMPEG_ARGS &&
make install
cd -
