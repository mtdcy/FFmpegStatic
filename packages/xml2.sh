#!/bin/bash
#
# MIT

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=http://xmlsoft.org/sources/libxml2-2.9.9.tar.gz
sha256=94fb70890143e3c6549f265cee93ec064c80a84c42ad0f23e85ee1fd6540a871

function install() {
    ARGS="--prefix=$PREFIX --disable-debug --enable-static --without-python --with-lzma"
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
cd libxml2-2.9.9 &&
install || { error "build libxml2 failed"; exit 1; }


