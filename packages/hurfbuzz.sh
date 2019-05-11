#!/bin/bash
#
# Old MIT
# for libass

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://github.com/harfbuzz/harfbuzz/releases/download/2.4.0/harfbuzz-2.4.0.tar.bz2
sha256=b470eff9dd5b596edf078596b46a1f83c179449f051a469430afc15869db336f

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
cd harfbuzz-2.4.0 &&
install || { error "build harfbuzz failed"; exit 1; }

