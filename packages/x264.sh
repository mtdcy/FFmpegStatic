#!/bin/bash
#
# GPL

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=ftp://ftp.videolan.org/pub/x264/snapshots/last_x264.tar.bz2
sha256=2c623eb8388df8d9a7962b56e5b02ebf2e55a41f929b928352f95c0385d1a4fa

function install() {
    ARGS="--prefix=$PREFIX --enable-static --enable-asm"
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" --enable-shared"
    fi
    AS=$NASM ./configure $ARGS || return 1
    make -j$NJOBS || return 1
    make install || return 1
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd x264-* &&
install || { error "build x264 failed"; exit 1; }

