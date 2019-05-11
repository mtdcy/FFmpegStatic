#!/bin/bash 

SOURCE=`pwd`/`dirname $0`
WORKSPACE=`pwd`/build
source $SOURCE/packages/cbox.sh

# 1. for release, it's better to build a huge bundle. but for project use, huge bundle takes too much resources
# global options
export BUILD_HUGE=${BUILD_HUGE:=1}
export BUILD_GPL=${BUILD_GPL:=0}
export BUILD_SHARED=${BUILD_SHARED:=0}
export BUILD_DEMUXER=${BUILD_DEMUXER:=1}
export BUILD_MUXER=${BUILD_MUXER:=${BUILD_HUGE}}
export BUILD_DECODER=${BUILD_DECODER:=1}
export BUILD_ENCODER=${BUILD_ENCODER:=${BUILD_HUGE}}
export NJOBS=${NJOBS:=4}
export BUILD_TEST=${BUILD_TEST:=1}

# local options
BUILD_DEPS=${BUILD_DEPS:=1}

echo "BUILD_DEPS: $BUILD_DEPS"
echo "BUILD_HUGE: $BUILD_HUGE"
echo "BUILD_GPL: $BUILD_GPL"
echo "NJOBS: $NJOBS"
echo "SOURCE: $SOURCE"
echo "WORKSPACE: $WORKSPACE"
pause "Please check build options..."

CC=`which cc`
CXX=`which c++`
AR=`which ar`
AS=`which as`
LD=`which ld`
RANLIB=`which ranlib`
STRIP=`which strip`
MAKE=`which make`
PKG_CONFIG=`which pkg-config`
SYSROOT=/
if [[ "$OSTYPE" == "darwin"* ]]; then
    CC="`xcrun --find cc` -isysroot `xcrun --show-sdk-path`"
    CXX="`xcrun --find c++` -isysroot `xcrun --show-sdk-path`"
    AR=`xcrun --find ar`
    AS=`xcrun --find as`
    LD=`xcrun --find ld`
    RANLIB=`xcrun --find ranlib`
    STRIP=`xcrun --find strip`
    MAKE=`xcrun --find make`
    PKG_CONFIG=`xcrun --find pkg-config`
    SYSROOT=`xcrun --show-sdk-path`
fi

export CC="$CC"
export CXX="$CXX"
export CPP="$CC -E"
export AR=$AR
export AS=$AS
export LD=$LD
export RANLIB=$RANLIB
export STRIP=$STRIP
export MAKE=$MAKE
export PKG_CONFIG=$PKG_CONFIG
export SYSROOT=$SYSROOT
export PREFIX=$WORKSPACE/$OSTYPE
export CFLAGS=-I$PREFIX/include
export CXXFLAGS=-I$PREFIX/include 
export LDFLAGS=-L$PREFIX/lib
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig

# https://cmake.org/cmake/help/v3.12/manual/cmake-env-variables.7.html
export CMAKE_ARGS=" -DCMAKE_MAKE=$MAKE"

echo "CC: $CC"
echo "CXX: $CXX"
echo "CPP: $CPP"
echo "AR: $AR"
echo "AS: $AS"
echo "LD: $LD"
echo "SYSROOT: $SYSROOT"
echo "PREFIX: $PREFIX"
echo "CFLAGS: $CFLAGS"
echo "CXXFLAGS: $CXXFLAGS"
echo "LDFLAGS: $LDFLAGS"
echo "MAKE: $MAKE"
echo "PKG_CONFIG: $PKG_CONFIG"
echo "PKG_CONFIG_PATH: $PKG_CONFIG_PATH"
pause "Please check compiler..."

function build_package() {
    $SHELL $1 || exit 1
}

# clear 
[ $BUILD_DEPS -eq 1 ] && rm -rf $PREFIX
mkdir -p $WORKSPACE && cd $WORKSPACE

# basic libs
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/zlib.sh 
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/bzip2.sh
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/lzma.sh
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/iconv.sh 

# demuxers & muxers
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/xml2.sh 

# audio libs
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/soxr.sh 
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/lame.sh         # mp3
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/ogg.sh 
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/vorbis.sh       # vorbis
[ $BUILD_DEPS -eq 1 -a $BUILD_GPL -eq 1 ] && build_package $SOURCE/packages/amr.sh 
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/opus.sh 
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/aac.sh          # aac

# video libs
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/theora.sh       # theora
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/vpx.sh          # vp8 & vp9
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/openh264.sh     # h264
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/kvazaar.sh      # h265

# image libs
# FIXME: find out the right dependency between jpeg & png & webp & tiff
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/png.sh          # png 
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/gif.sh          # gif
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/turbojpeg.sh    # jpeg
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/tiff.sh         # depends on jpeg
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/webp.sh         # depends on jpeg&png&tiff
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/openjpeg.sh     # depends on png&tiff

# text libs
#[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/hurfbuzz.s    # need by libass
#[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/fribidi.sh    # need by libass
#[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/ass.sh            

build_package $SOURCE/packages/ffmpeg.sh 

