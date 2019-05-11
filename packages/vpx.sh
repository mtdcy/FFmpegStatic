#!/bin/bash
#
# BSD 3-Clause

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://github.com/webmproject/libvpx/archive/v1.8.0.tar.gz
sha256=86df18c694e1c06cc8f83d2d816e9270747a0ce6abe316e93a4f4095689373f6

function install() {
    ARGS="--prefix=$PREFIX --disable-debug --enable-static --enable-unit-tests --enable-vp8 --enable-vp9"
    ARGS+=" --extra-cflags=$CFLAGS --extra-cxxflags=$CPPFLAGS"
    if [ $BUILD_SHARED -eq 1 ]; then
        # build shared failed with clang
        #ARGS+=" --enable-shared --enable-pic"
        ARGS+=" --disable-shared"
    else
        ARGS+=" --disable-shared"
    fi

    ./configure $ARGS || return 1
    #if [[ "$OSTYPE" == "darwin"* ]]; then
    #    sed -i 's/-Wl,--no-undefined/-Wl,-undefined,error/g' build/make/Makefile
    #    sed -i 's/-Wl,--no-undefined/-Wl,-undefined,error/g' Makefile
    #fi

    make -j$NJOBS || return 1
    make install || return 1
}

download $url $sha256 libvpx-`basename $url` &&
extract libvpx-`basename $url` && 
cd libvpx-1.8.0 &&
install || { error "build libvpx failed"; exit 1; }

