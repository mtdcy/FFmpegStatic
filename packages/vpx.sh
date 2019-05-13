#!/bin/bash
#
# BSD 3-Clause

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://github.com/webmproject/libvpx/archive/v1.8.0.tar.gz
sha256=86df18c694e1c06cc8f83d2d816e9270747a0ce6abe316e93a4f4095689373f6

function install() {
    ARGS="--prefix=$PREFIX --disable-debug --enable-static --enable-vp8 --enable-vp9 --disable-examples"
    ARGS+=" --extra-cflags=$CFLAGS --extra-cxxflags=$CPPFLAGS"
    ARGS+=" --as=yasm"      # libvpx prefer yasm
    #ARGS+=" --disable-libyuv"
    if [ $BUILD_SHARED -eq 1 ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # build shared failed with clang
            ARGS+=" --disable-shared"
        elif [[ "$OSTYPE" == "msys" ]]; then
            # shared not supported on win32
            ARGS+=" --disable-shared"
        else
            ARGS+=" --enable-shared --enable-pic"
        fi
    else
        ARGS+=" --disable-shared"
    fi

    # https://stackoverflow.com/questions/43152633/invalid-register-for-seh-savexmm-in-cygwin
    if [[ "$OSTYPE" == "msys" ]]; then
        ARGS+=" --extra-cflags=-fno-asynchronous-unwind-tables"
        # FIXME: failed to build gtest
        ARGS+=" --disable-unit-tests"
    fi

    info "libvpx: ./configure $ARGS"
    ./configure $ARGS || return 1
    #if [[ "$OSTYPE" == "darwin"* ]]; then
    #    sed -i 's/-Wl,--no-undefined/-Wl,-undefined,error/g' build/$MAKE/Makefile
    #    sed -i 's/-Wl,--no-undefined/-Wl,-undefined,error/g' Makefile
    #fi

    $MAKE -j$NJOBS install || return 1  # run test automatically

    sed -i '/libvpx:/d' $PREFIX/LIBRARIES.txt || return
    echo "libvpx: 1.8.0" >> $PREFIX/LIBRARIES.txt || return
}

download $url $sha256 libvpx-`basename $url` &&
extract libvpx-`basename $url` && 
cd libvpx-*/ &&
install || { error "build libvpx failed"; exit 1; }

