#!/bin/bash 
[ -z $BASH ] && { exec bash "$0" "$@" || exit; }

cd `dirname $0` && SOURCE=`pwd` && cd -
source $SOURCE/build/cbox.sh

export LC_ALL=C
export LANG=C
umask 022
#set -e # exit on error
#set -x

# working directory
TGT=$OSTYPE
mkdir -p $SOURCE/$TGT
cd $SOURCE/$TGT

# 1. for release, it's better to build a huge bundle. but for project use, huge bundle takes too much resources
# global options
export BUILD_HUGE=${BUILD_HUGE:=0}
export BUILD_SHARED=${BUILD_SHARED:=0}
export BUILD_GPL=${BUILD_GPL:=0}
export BUILD_NONFREE=${BUILD_NONFREE:=0}
export BUILD_TEST=${BUILD_TEST:=1}
export NJOBS=${NJOBS:=4}
export BUILD_FRAMEWORK=${BUILD_FRAMEWORK:=1}    # build framework for mac

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

if [[ "$OSTYPE" == "darwin"* ]]; then
    CC=`xcrun --find gcc`
    CXX=`xcrun --find g++`
    AR=`xcrun --find ar`
    AS=`xcrun --find as`
    LD=`xcrun --find ld`
    RANLIB=`xcrun --find ranlib`
    STRIP=`xcrun --find strip`
    MAKE=`xcrun --find make`
    PKG_CONFIG=`xcrun --find pkg-config`
    NASM=`xcrun --find nasm`
    YASM=`xcrun --find yasm`
    CMAKE=`xcrun --find cmake`
else
    [[ "$OSTYPE" == "msys" ]] && suffix=".exe"
    CC=`which gcc$suffix`
    CXX=`which g++$suffix`
    AR=`which ar$suffix`
    AS=`which as$suffix`
    LD=`which ld$suffix`
    RANLIB=`which ranlib$suffix`
    STRIP=`which strip$suffix`
    MAKE=`which make$suffix`
    PKG_CONFIG=`which pkg-config$suffix`
    NASM=`which nasm$suffix`
    YASM=`which yasm$suffix`
    CMAKE=`which cmake$suffix`
fi

PREFIX=$PWD/prebuilts

# common flags for c/c++
FLAGS="-g -O2 -DNDEBUG -fPIC -DPIC"  # build with debug info & PIC

CFLAGS=$FLAGS
CXXFLAGS=$FLAGS
CPP="$CC -E"
CPPFLAGS=-I$PREFIX/include
LDFLAGS=-L$PREFIX/lib
[ $BUILD_SHARED -eq 1 ] && LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib"

# pkg-config
PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig
LD_LIBRARY_PATH=$PREFIX/lib     # for run test

# cmake
# cmake may affect by some environment variables but do no handle it right
# cmake using a mixed path style with MSYS Makefiles, why???
CMAKE_COMMON_ARGS="-DCMAKE_INSTALL_PREFIX=$PREFIX
		   -DCMAKE_BUILD_TYPE=RelWithDebInfo 
		   -DCMAKE_C_COMPILER=$CC
		   -DCMAKE_CXX_COMPILER=$CXX
		   -DCMAKE_C_FLAGS=\"$CFLAGS\"
		   -DCMAKE_CXX_FLAGS=\"$CXXFLAGS\"
		   -DCMAKE_ASM_NASM_COMPILER=$NASM
		   -DCMAKE_ASM_YASM_COMPILER=$YASM
		   -DCMAKE_AR=$AR
		   -DCMAKE_LINKER=$LD
		   -DCMAKE_MODULE_LINKER_FLAGS=\"$LDFLAGS\"
		   -DCMAKE_EXE_LINKER_FLAGS=\"$LDFLAGS\"
		   -DCMAKE_MAKE_PROGRAM=$MAKE"
[[ "$OSTYPE" == "msys" ]] && CMAKE_COMMON_ARGS="$CMAKE_COMMON_ARGS -G\"MSYS Makefiles\""

info "=> $PREFIX"
echo "CC: $CC $CFLAGS"
echo "CPP: $CPP $CPPFLAGS"
echo "CXX: $CXX $CXXFLAGS"
echo "LD: $LD $LDFLAGS"
echo "AR: $AR"
echo "AS: $AS"
echo "NASM: $NASM"
echo "YASM: $YASM"
echo "MAKE: $MAKE"
echo "CMAKE: $CMAKE $CMAKE_COMMON_ARGS"
echo "PKG_CONFIG: $PKG_CONFIG $PKG_CONFIG_PATH"

export PREFIX CC CFLAGS CPP CPPFLAGS CXX CXXFLAGS 
export LD LDFLAGS PKG_CONFIG PKG_CONFIG_PATH 
export AR AS NASM YASM RANLIB STRIP MAKE 
export LD_LIBRARY_PATH 
export CMAKE CMAKE_COMMON_ARGS
pause "Please check compiler..."

function build_package() {
    bash $1 || exit 1
}

# clear 
[ $BUILD_DEPS -eq 1 ] && rm -rf $PREFIX
[ -d $PREFIX ] || mkdir -p $PREFIX

# always build all deps
# basic libs
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/iconv.sh
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/zlib.sh 
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/bzip2.sh
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/lzma.sh

# audio libs
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/soxr.sh 
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/lame.sh        # mp3
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/ogg.sh 
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/vorbis.sh      # vorbis
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/amr.sh 
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/opus.sh 
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/fdk-aac.sh     # aac

# image libs
# FIXME: find out the right dependency between jpeg & png & webp & tiff
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/png.sh          # png 
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/gif.sh          # gif
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/turbojpeg.sh    # jpeg
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/tiff.sh         # depends on jpeg
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/webp.sh         # depends on jpeg&png&tiff
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/openjpeg.sh     # depends on png&tiff, for jpeg2000

# video libs
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/theora.sh      # theora
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/vpx.sh         # vp8 & vp9
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/openh264.sh    # h264, LGPL
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/kvazaar.sh     # h265, LGPL
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/x264.sh        # h264, GPL
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/x265.sh        # h265, GPL
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/xvidcore.sh    # xvid, GPL

# text libs
#[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/hurfbuzz.s    # need by libass
#[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/fribidi.sh    # need by libass
#[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/ass.sh            

# demuxers & muxers
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/xml2.sh        # need by libavformat:dashdec
[ $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/sdl2.sh        # need by ffplay

# video postprocessing
[ $BUILD_GPL -eq 1 -a $BUILD_DEPS -eq 1 ] && build_package $SOURCE/build/frei0r.sh      # frei0r, GPL

build_package $SOURCE/build/ffmpeg.sh 

LIBS=(libavutil libavcodec libavformat libavfilter libswresample libswscale libavdevice libpostproc)
for lib in ${LIBS[@]}; do
    [ ! -d $PREFIX/include/$lib ] && continue;

    mkdir -p $SOURCE/include/$lib 
    cp $PREFIX/include/$lib/* $SOURCE/include/$lib/
done
