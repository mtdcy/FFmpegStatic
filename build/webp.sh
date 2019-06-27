#!/bin/bash
#
# 

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-1.0.2.tar.gz
sha256=3d47b48c40ed6476e8047b2ddb81d93835e0ca1b8d3e8c679afbb3004dd564b1

prepare_pkg_source $url $sha256 $SOURCE/packages/`basename $url` && cd libwebp-*/

ARGS="--prefix=$PREFIX --disable-debug --enable-libwebpdecoder --enable-libwebpdemux --enable-libwebpmux"
if [ $BUILD_SHARED -eq 1 ]; then
    ARGS+=" --enable-shared --disable-static"
else
    ARGS+=" --disable-shared --enable-static"
fi

info "libwebp: ./configure $ARGS"
./configure $ARGS || error "configure failed"
$MAKE -j$NJOBS install || error "make install failed"

if [ $BUILD_TEST -eq 1 ]; then 
    $MAKE check || error "check failed"
fi
