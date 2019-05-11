#!/bin/bash
#
# BSD 3-Clause

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://downloads.sourceforge.net/project/opencore-amr/fdk-aac/fdk-aac-2.0.0.tar.gz
sha256=f7d6e60f978ff1db952f7d5c3e96751816f5aef238ecf1d876972697b85fd96c

function install() {
    ARGS="--prefix=$PREFIX --disable-debug --enable-static --enable-example"
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
cd fdk-aac-2.0.0 &&
install || { error "build libogg failed"; exit 1; }
