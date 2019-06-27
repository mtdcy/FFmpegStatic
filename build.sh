#!/bin/bash 

cd `dirname $0` && SOURCE=`pwd` && cd -
source $SOURCE/build/cbox.sh

# 1. for release, it's better to build a huge bundle. but for project use, huge bundle takes too much resources
# global options
export BUILD_SHARED=${BUILD_SHARED:=0}
export BUILD_GPL=${BUILD_GPL:=0}
export BUILD_NONFREE=${BUILD_NONFREE:=0}
export BUILD_TEST=${BUILD_TEST:=1}
export NJOBS=${NJOBS:=4}

# local options
BUILD_DEPS=${BUILD_DEPS:=1}

info "$SOURCE => $PWD"
echo "BUILD_SHARED: $BUILD_SHARED"
echo "BUILD_GPL: $BUILD_GPL"
echo "BUILD_NONFREE: $BUILD_NONFREE"
echo "BUILD_TEST: $BUILD_TEST"
echo "BUILD_DEPS: $BUILD_DEPS"
echo "NJOBS: $NJOBS"
pause "Please check build options..."

CC=`which gcc`
CXX=`which g++`
AR=`which ar`
AS=`which as`
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

PREFIX=$PWD/$OSTYPE 
[ $BUILD_SHARED -eq 1 ] && PREFIX="$PREFIX-shared"

FLAGS="-g -O2 -DNDEBUG"  # build with debug info
[[ "$OSTYPE" == "linux"* ]] && FLAGS="$FLAGS -fPIC -DPIC"
#[[ "$OSTYPE" == "darwin"* ]] && FLAGS="$FLAGS -isysroot `xcrun --show-sdk-path`"

CFLAGS=$FLAGS
CXXFLAGS=$FLAGS
CPP="$CC -E"
CPPFLAGS=-I$PREFIX/include
LDFLAGS=-L$PREFIX/lib
[ $BUILD_SHARED -eq 1 ] && LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib"

# as
NASM=`which nasm`
YASM=`which yasm`

# pkg-config
PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig
LD_LIBRARY_PATH=$PREFIX/lib     # for run test

# cmake
CMAKE=`which cmake`
CMAKE_COMMON_ARGS="-DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=RelWithDebInfo"
[[ "$OSTYPE" == "msys" ]] && CMAKE_COMMON_ARGS="$CMAKE_COMMON_ARGS -G\"MSYS Makefiles\""

info "=> $PREFIX"
echo "CC: $CC $CFLAGS"
echo "CPP: $CPP $CPPFLAGS"
echo "CXX: $CXX $CXXFLAGS"
echo "LD: $LD $LDFLAGS"
echo "PKG_CONFIG: $PKG_CONFIG $PKG_CONFIG_PATH"
echo "AR: $AR"
echo "AS: $AS"
echo "NASM: $NASM"
echo "YASM: $YASM"
echo "MAKE: $MAKE"
echo "CMAKE: $CMAKE $CMAKE_COMMON_ARGS"

export PREFIX CC CFLAGS CPP CPPFLAGS CXX CXXFLAGS 
export LD LDFLAGS PKG_CONFIG PKG_CONFIG_PATH 
export AR AS NASM YASM RANLIB STRIP MAKE 
export LD_LIBRARY_PATH 
export CMAKE CMAKE_COMMON_ARGS
pause "Please check compiler..."

function build_package() {
    $SHELL $1 || exit 1
}

# clear 
[ $BUILD_DEPS -eq 1 ] && rm -rf $PREFIX
[ -d $PREFIX ] || mkdir -p $PREFIX

# basic libs
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/iconv.sh 
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/zlib.sh 
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/bzip2.sh
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/lzma.sh

# audio libs
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/soxr.sh 
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/lame.sh         # mp3
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/ogg.sh 
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/vorbis.sh       # vorbis
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/amr.sh 
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/opus.sh 
[ $BUILD_DEPS -eq 1 -a $BUILD_NONFREE -eq 1 ] && build_package $SOURCE/build/fdk-aac.sh  # aac

# image libs
# FIXME: find out the right dependency between jpeg & png & webp & tiff
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/png.sh          # png 
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/gif.sh          # gif
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/turbojpeg.sh    # jpeg
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/tiff.sh         # depends on jpeg
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/webp.sh         # depends on jpeg&png&tiff
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/openjpeg.sh     # depends on png&tiff

# video libs
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/theora.sh       # theora
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/vpx.sh          # vp8 & vp9
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/openh264.sh     # h264
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/kvazaar.sh      # h265
if [ $BUILD_GPL -eq 1 ]; then 
    [ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/x264.sh     # h264
    [ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/x265.sh     # h265
    [ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/xvidcore.sh # xvid
    [ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/frei0r.sh   # frei0r 
fi

# text libs
#[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/hurfbuzz.s    # need by libass
#[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/fribidi.sh    # need by libass
#[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/ass.sh            

# demuxers & muxers
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/xml2.sh        # need by libavformat:dashdec

build_package $SOURCE/build/ffmpeg.sh 

cd ffmpeg-* && ffmpeg=$PWD && cd -
cmd="cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DFFMPEG_PREBUILTS=$PREFIX -DFFMPEG_SOURCES=$ffmpeg"
[[ "$OSTYPE" == "darwin"* ]] && cmd="$cmd -DCMAKE_INSTALL_PREFIX=$HOME/Library/Frameworks" || cmd="$cmd -DCMAKE_INSTALL_PREFIX=$PWD/out"
[[ "$OSTYPE" == "msys" ]] && cmd="$cmd -G\"MSYS Makefiles\""
[[ "$OSTYPE" == "darwin"* ]] && cmd="$cmd -GXcode"
cmd="$cmd $SOURCE"

[[ "$OSTYPE" == "darwin"* ]] && cmd="$cmd && xcodebuild -alltargets -config Release" || cmd="$cmd && $MAKE install"

info $cmd
[ -e $PWD/out ] && rm -rf $PWD/out
[ -e CMakeCache.txt ] && rm CMakeCache.txt
[[ "$OSTYPE" == "darwin"* ]] && unset LD     # cmake take LD instead CC as C compiler, why?
eval $cmd
