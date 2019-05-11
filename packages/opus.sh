#!/bin/bash
#
# BSD 3-Clause

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://archive.mozilla.org/pub/opus/opus-1.3.1.tar.gz
sha256=65b58e1e25b2a114157014736a3d9dfeaad8d41be1c8179866f144a2fb44ff9d

function install() {
    ARGS="--prefix=$PREFIX --disable-debug --enable-static"
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" --enable-shared"
    else
        ARGS+=" --disable-shared"
    fi
    ./configure $ARGS || return 1
    make -j$NJOBS || return 1
    if [ $BUILD_TEST -eq 1 ]; then 
        make check || return 1
    fi
    make install || return 1
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd opus-1.3.1 &&
install || { error "build libogg failed"; exit 1; }



