#!/bin/bash
#
# 

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-1.0.2.tar.gz
sha256=3d47b48c40ed6476e8047b2ddb81d93835e0ca1b8d3e8c679afbb3004dd564b1

function install() {
    ARGS="--prefix=$PREFIX --disable-debug --enable-static --enable-libwebpdecoder --enable-libwebpdemux --enable-libwebpmux"
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" --enable-shared"
    else
        ARGS+=" --disable-shared"
    fi

    info "libwebp: ./configure $ARGS"
    ./configure $ARGS || return 1
    $MAKE -j$NJOBS install || return 1

    if [ $BUILD_TEST -eq 1 ]; then 
        $MAKE check || return
    fi

    sed -i '/libwebp:/d' $PREFIX/LIBRARIES.txt || return
    echo "libwebp: 1.0.2" >> $PREFIX/LIBRARIES.txt || return
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd libwebp-*/ &&
install || { error "build webp failed"; exit 1; }


