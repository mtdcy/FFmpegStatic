#!/bin/bash
#
# BSD 3-Clause

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://github.com/webmproject/libvpx/archive/v1.8.0.tar.gz
sha256=86df18c694e1c06cc8f83d2d816e9270747a0ce6abe316e93a4f4095689373f6

prepare_pkg_source $url $sha256 $SOURCE/packages/libvpx-`basename $url` && cd libvpx-*/

ARGS="--prefix=$PREFIX --disable-debug --enable-vp8 --enable-vp9 --disable-examples --disable-multithread"
ARGS+=" --extra-cflags=\"$CFLAGS\" --extra-cxxflags=\"$CPPFLAGS\""
ARGS+=" --as=yasm"          # libvpx prefer yasm
#ARGS+=" --disable-libyuv"
if [ $BUILD_SHARED -eq 1 ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # build shared failed with clang
        ARGS+=" --disable-shared --enable-static"
    elif [[ "$OSTYPE" == "msys" ]]; then
        # shared not supported on win32
        ARGS+=" --disable-shared --enable-static"
    else
        ARGS+=" --enable-shared --disable-static --enable-pic"
    fi
else
    ARGS+=" --disable-shared --enable-static"
fi

# https://stackoverflow.com/questions/43152633/invalid-register-for-seh-savexmm-in-cygwin
if [[ "$OSTYPE" == "msys" ]]; then
    ARGS+=" --extra-cflags=-fno-asynchronous-unwind-tables"
    # FIXME: failed to build gtest
    ARGS+=" --disable-unit-tests"
fi

cmd="./configure $ARGS"
info "libvpx: $cmd"
eval $cmd || error "$cmd failed"
#if [[ "$OSTYPE" == "darwin"* ]]; then
#    sed -i 's/-Wl,--no-undefined/-Wl,-undefined,error/g' build/$MAKE/Makefile
#    sed -i 's/-Wl,--no-undefined/-Wl,-undefined,error/g' Makefile
#fi

$MAKE -j$NJOBS install || error "make install failed" # run test automatically
