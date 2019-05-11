#!/bin/bash
#
# 

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://downloads.sourceforge.net/libpng/libpng-1.6.37.tar.xz
sha256=505e70834d35383537b6491e7ae8641f1a4bed1876dbfe361201fc80868d88ca

function install() {
    ARGS="--prefix=$PREFIX --disable-debug --enable-static --enable-hardware-optimizations"
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" --enable-shared"
    else
        ARGS+=" --disable-shared"
    fi
    ./configure $ARGS || return 1
    make -j$NJOBS || return 1
    if [ $BUILD_TEST -eq 1 ]; then
       make test || return 1      # very slow
    fi
    make install || return 1
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd libpng-1.6.37 &&
install || { error "build png failed"; exit 1; }


