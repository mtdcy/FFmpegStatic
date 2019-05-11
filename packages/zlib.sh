#!/bin/bash
# usage: zlib.sh <install_prefix>

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://zlib.net/zlib-1.2.11.tar.gz
sha256=c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1

function install() {
    ARGS="--prefix=$PREFIX"
    if [ $BUILD_SHARED -eq 0 ]; then
        ARGS+=" --static"
    fi
    ./configure $ARGS || return 1
    make -j$NJOBS || return 1
    if [ $BUILD_TEST -eq 1 ]; then 
        make test || return 1
    fi
    make install || return 1
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd zlib-1.2.11 &&
install || { error "build zlib failed"; exit 1; }
