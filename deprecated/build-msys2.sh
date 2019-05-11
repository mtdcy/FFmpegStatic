#!/bin/bash 
SOURCE=`dirname $0`
source $SOURCE/cbox.sh

# for Windows: avoid build shared libraries (.dll), which cause => *.lib *.dll.a
# config 
# Note: 
# 1. for release, it's better to build a huge bundle. but for project use, huge bundle takes too much resources
BUILD_HUGE=${BUILD_HUGE:=1}
BUILD_DEPS=${BUILD_DEPS:=1}
BUILD_GPL=${BUILD_GPL:=0}
BUILD_DEMUXER=${BUILD_DEMUXER:=1}
BUILD_MUXER=${BUILD_MUXER:=${BUILD_HUGE}}
BUILD_DECODER=${BUILD_DECODER:=1}
BUILD_ENCODER=${BUILD_ENCODER:=${BUILD_HUGE}}
NJOBS=${NJOBS:=4}

info "huge ${BUILD_HUGE}, deps ${BUILD_DEPS}, gpl ${BUILD_GPL}"
info "demuxer ${BUILD_DEMUXER}, muxer ${BUILD_MUXER}"
info "decoder ${BUILD_DECODER}, encoder ${BUILD_ENCODER}"

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
$SOURCE/download.sh || { error "download packages failed"; exit 1; }

# setup env
PREFIX=$WS/prebuilts
info "PREFIX: $PREFIX"
mkdir -p $WS/build/
cd $WS/build 

if [ $BUILD_DEPS -eq 1 ]; then 
# zlib - zlib license 
ZLIB_ARGS="--prefix=$PREFIX"
tar -xf $WS/packages/zlib-1.2.11.tar.gz  &&
cd zlib-1.2.11  &&
DESTDIR=$PREFIX INCLUDE_PATH="/include" LIBRARY_PATH="/lib" BINARY_PATH="/bin" make install -f win32/Makefile.gcc || { error "build zlib failed"; exit 1; }
cd -

# bzip2 - 
BZIP2_ARGS="PREFIX=$PREFIX"
tar -xf $WS/packages/bzip2-1.0.6.tar.gz &&
cd bzip2-1.0.6 &&
make install $BZIP2_ARGS || { error "build bzip2 failed"; exit 1; }
cd -

# lzma - in the public domain
XZ_ARGS="--prefix=$PREFIX --disable-debug --disable-dependency-tracking --disable-silent-rules"
tar -xf $WS/packages/xz-5.2.4.tar.bz2  &&
cd xz-5.2.4  &&
./configure $XZ_ARGS && 
make -j$NJOBS && make install || { error "build lzma failed"; exit 1; }
cd -

# libiconv - LGPL
LIBICONV_ARGS="--prefix=$PREFIX --disable-dependency-tracking --disable-debug --enable-extra-encodings --enable-static"
tar -xf $WS/packages/libiconv-1.15.tar.gz &&
cd libiconv-1.15  &&
./configure $LIBICONV_ARGS && 
make -j$NJOBS && make install || { error "build libiconv failed"; exit 1; }
cd -

fi  # BUILD_DEPS

# FFmpeg - GPL or LGPL
FFMPEG_ARGS="--prefix=$PREFIX --extra-ldflags=-L$PREFIX/lib --extra-cflags=-I$PREFIX/include --disable-shared --enable-static --enable-hardcoded-tables --host-cflags= --host-ldflags= "
if [ $BUILD_HUGE -eq 1 ]; then 
    FFMPEG_ARGS+=" --enable-decoders --enable-encoders --enable-demuxers --enable-muxers"
else
    FFMPEG_ARGS+=" --disable-decoders --disable-encoders --disable-demuxers --disable-muxers"

    FFMPEG_ARGS+=" --enable-decoder=$A_DECODERS,$V_DECODERS,$S_DECODERS"

    [ $BUILD_ENCODER -eq 1 ] && FFMPEG_ARGS+=" --enable-encoder=$A_ENCODERS,$V_ENCODERS,$S_ENCODERS"

    FFMPEG_ARGS+=" --enable-demuxer=$DEMUXERS"
    [ $BUILD_MUXER -eq 1 ] && FFMPEG_ARGS+=" --enable-muxer=$MUXER"
fi
info "ARGS: $FFMPEG_ARGS"

tar -xf $WS/packages/ffmpeg-4.1.tar.bz2 &&
cd ffmpeg-4.1 &&
./configure $FFMPEG_ARGS &&
make clean && make -j$NJOBS && make install || { error "build ffmpeg failed"; exit 1; }
cd -
