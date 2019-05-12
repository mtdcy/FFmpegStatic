#!/bin/bash
#
# 

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://download.osgeo.org/libtiff/tiff-4.0.10.tar.gz
sha256=2c52d11ccaf767457db0c46795d9c7d1a8d8f76f68b0b800a3dfe45786b996e4

function install() {
    ARGS="--prefix=$PREFIX --disable-debug --enable-rpath --enable-static --disable-webp"
    ARGS+=" --enable-lzma"
    ARGS+=" --disable-webp"     # loop dependency between tiff & webp
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" --enable-shared"
    else
        ARGS+=" --disable-shared"
    fi

    info "libtiff: ./configure $ARGS"
    ./configure $ARGS || return 1
    $MAKE -j$NJOBS || return 1
    $MAKE install || return 1
    sed -i '/libtiff:/d' $PREFIX/LIBRARIES.txt || return
    echo "libtiff: 4.0.10" >> $PREFIX/LIBRARIES.txt || return
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd tiff-4.0.10 &&
install || { error "build tiff failed"; exit 1; }

