#!/bin/bash
#
# 

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://download.osgeo.org/libtiff/tiff-4.0.10.tar.gz
sha256=2c52d11ccaf767457db0c46795d9c7d1a8d8f76f68b0b800a3dfe45786b996e4

prepare_pkg_source $url $sha256 $SOURCE/packages/`basename $url` && cd tiff-*/

ARGS="--prefix=$PREFIX --disable-debug --disable-webp"
ARGS+=" --enable-lzma"
ARGS+=" --disable-webp"     # loop dependency between tiff & webp
ARGS+=" --disable-zstd"
if [ $BUILD_SHARED -eq 1 ]; then
    ARGS+=" --enable-shared --disable-static --enable-rpath"
else
    ARGS+=" --disable-shared --enable-static"
fi

info "libtiff: ./configure $ARGS"
./configure $ARGS || error "configure failed"
$MAKE -j$NJOBS install || error "make install failed"
