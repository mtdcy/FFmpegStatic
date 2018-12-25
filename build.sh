#!/bin/bash 
cd `dirname $0`
source cbox.sh

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

# zlib
ZLIB_ARGS="--prefix=$PREFIX"
tar -xvf $WS/packages/zlib-1.2.11.tar.gz  &&
cd zlib-1.2.11  &&
./configure $ZLIB_ARGS && 
make install 
cd -

# lzma 
XZ_ARGS="--prefix=$PREFIX --disable-debug --disable-dependency-tracking --disable-silent-rules"
tar -xvf $WS/packages/xz-5.2.4.tar.bz2  &&
cd xz-5.2.4  &&
./configure $XZ_ARGS && 
make install
cd -

# libiconv
LIBICONV_ARGS="--prefix=$PREFIX --disable-dependency-tracking --disable-debug --enable-extra-encodings --enable-static"
tar -xvf $WS/packages/libiconv-1.15.tar.gz &&
cd libiconv-1.15  &&
./configure $LIBICONV_ARGS && 
make install
cd -

# FFmpeg 
FFMPEG_ARGS="--prefix=$PREFIX --extra-ldflags="-L$PREFIX/lib" --extra-cflags="-I$PREFIX/include" --enable-shared --enable-static --enable-rpath --enable-pthreads --enable-hardcoded-tables --cc=clang --host-cflags= --host-ldflags= --enable-opencl --enable-videotoolbox"
tar -xvf $WS/packages/ffmpeg-4.1.tar.bz2 &&
cd ffmpeg-4.1 &&
./configure $FFMPEG_ARGS &&
make install
cd -
