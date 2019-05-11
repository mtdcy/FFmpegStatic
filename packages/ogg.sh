#!/bin/bash
#
# BSD 3-Clause

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://downloads.xiph.org/releases/ogg/libogg-1.3.3.tar.gz
sha256=c2e8a485110b97550f453226ec644ebac6cb29d1caef2902c007edab4308d985

function install() {
    ARGS="--prefix=$PREFIX --disable-debug --enable-static"
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" --enable-shared"
    else
        ARGS+=" --disable-shared"
    fi
    ./configure $ARGS || return 1
    make -j$NJOBS || return 1
    make install || return 1
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd libogg-1.3.3 &&
install || { error "build libogg failed"; exit 1; }


