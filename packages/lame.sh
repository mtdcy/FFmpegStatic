#!/bin/bash
# usage: lame.sh <install_prefix>
# 
# License: LGPL

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://sourceforge.net/projects/lame/files/lame/3.100/lame-3.100.tar.gz
sha256=ddfe36cab873794038ae2c1210557ad34857a4b6bdc515785d1da9e175b1da1e

function install() {
    # Fix undefined symbol error _lame_init_old
    # https://sourceforge.net/p/lame/mailman/message/36081038/
    sed -i '/lame_init_old/d' include/libmp3lame.sym

    ARGS="--prefix=$PREFIX --disable-debug --enable-nasm --enable-static"
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" --enable-shared"
    else
        ARGS+=" --disable-shared"
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
cd lame-3.100 && 
install || { error "build lame failed"; exit 1; }

