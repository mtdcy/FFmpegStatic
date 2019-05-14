#!/bin/bash 

cd `dirname $0` && SOURCE=`pwd` && cd -
WORKSPACE=`pwd`/build
source $SOURCE/packages/cbox.sh

# 1. for release, it's better to build a huge bundle. but for project use, huge bundle takes too much resources
# global options
export BUILD_HUGE=${BUILD_HUGE:=1}
export BUILD_GPL=${BUILD_GPL:=0}
export BUILD_NONFREE=${BUILD_NONFREE:=0}
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
echo "BUILD_NONFREE: $BUILD_NONFREE"
echo "BUILD_TEST: $BUILD_TEST"
echo "NJOBS: $NJOBS"
echo "SOURCE: $SOURCE"
echo "WORKSPACE: $WORKSPACE"
pause "Please check build options..."

if [[ "$OSTYPE" == "darwin"* ]]; then
    CC="`xcrun --find cc` -isysroot `xcrun --show-sdk-path`"
    CXX="`xcrun --find c++` -isysroot `xcrun --show-sdk-path`"
    AR=`xcrun --find ar`
    AS=`xcrun --find as`
    NASM=`xcrun --find nasm`
    YASM=`xcrun --find yasm`
    LD=`xcrun --find ld`
    RANLIB=`xcrun --find ranlib`
    STRIP=`xcrun --find strip`
    MAKE=`xcrun --find make`
    PKG_CONFIG=`xcrun --find pkg-config`
else
    CC=`which gcc`
    CXX=`which g++`
    AR=`which ar`
    AS=`which as`
    NASM=`which nasm`
    YASM=`which yasm`
    LD=`which ld`
    RANLIB=`which ranlib`
    STRIP=`which strip`
    MAKE=`which make`
    PKG_CONFIG=`which pkg-config`
    if [[ "$OSTYPE" == "msys" ]]; then
        # using MSYS make which using shell to execute its command
        # for those who prefer windows cmd, switch to mingw32-make 
        # MAKE=`which mingw32-make`
        echo "msys"
    fi
fi

export PREFIX=$WORKSPACE/$OSTYPE
export CC="$CC"
export CFLAGS=-I$PREFIX/include
export CPP="$CC -E"
export CPPFLAGS=
export CXX="$CXX"
export CXXFLAGS=-I$PREFIX/include 
export LD=$LD
export LDFLAGS=-L$PREFIX/lib
export PKG_CONFIG=$PKG_CONFIG
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig
export AR=$AR
export AS=$AS
export NASM=$NASM
export YASM=$YASM 
export RANLIB=$RANLIB
export STRIP=$STRIP
export MAKE=$MAKE
# for run test
export LD_LIBRARY_PATH=$PREFIX/lib

echo "PREFIX: $PREFIX"
echo "CC: $CC CFLAGS: $CFLAGS"
echo "CPP: $CPP CPPFLAGS: $CPPFLAGS"
echo "CXX: $CXX CXXFLAGS: $CXXFLAGS"
echo "LD: $LD LDFLAGS: $LDFLAGS"
echo "PKG_CONFIG: $PKG_CONFIG PKG_CONFIG_PATH: $PKG_CONFIG_PATH"
echo "AR: $AR"
echo "AS: $AS"
echo "NASM: $NASM"
echo "YASM: $YASM"
echo "MAKE: $MAKE"
pause "Please check compiler..."

function build_package() {
    $SHELL $1 || exit 1
}

# clear 
[ $BUILD_DEPS -eq 1 ] && rm -rf $PREFIX
mkdir -p $WORKSPACE && cd $WORKSPACE
mkdir -p $PREFIX
touch $PREFIX/LIBRARIES.txt 

# basic libs
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/iconv.sh 
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/zlib.sh 
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/bzip2.sh
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/lzma.sh

# audio libs
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/soxr.sh 
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/lame.sh         # mp3
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/ogg.sh 
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/vorbis.sh       # vorbis
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/amr.sh 
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/opus.sh 
[ $BUILD_DEPS -eq 1 -a $BUILD_NONFREE -eq 1 ] && build_package $SOURCE/packages/fdk-aac.sh  # aac

# image libs
# FIXME: find out the right dependency between jpeg & png & webp & tiff
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/png.sh          # png 
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/gif.sh          # gif
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/turbojpeg.sh    # jpeg
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/tiff.sh         # depends on jpeg
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/webp.sh         # depends on jpeg&png&tiff
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/openjpeg.sh     # depends on png&tiff

# video libs
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/theora.sh       # theora
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/vpx.sh          # vp8 & vp9
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/openh264.sh     # h264
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/kvazaar.sh      # h265
if [ $BUILD_GPL -eq 1 ]; then 
    [ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/x264.sh     # h264
    [ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/x265.sh     # h265
    [ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/xvidcore.sh # xvid
    [ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/frei0r.sh   # frei0r 
fi

# text libs
#[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/hurfbuzz.s    # need by libass
#[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/fribidi.sh    # need by libass
#[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/ass.sh            

# demuxers & muxers
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/packages/xml2.sh 

build_package $SOURCE/packages/ffmpeg.sh 

