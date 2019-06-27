#!/bin/bash
#
# 

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://downloads.sourceforge.net/libpng/libpng-1.6.37.tar.xz
sha256=505e70834d35383537b6491e7ae8641f1a4bed1876dbfe361201fc80868d88ca

prepare_pkg_source $url $sha256 $SOURCE/packages/`basename $url` && cd libpng-*/

ARGS="--prefix=$PREFIX --disable-debug --enable-hardware-optimizations"
if [ $BUILD_SHARED -eq 1 ]; then
    ARGS+=" --enable-shared --disable-static"
else
    ARGS+=" --disable-shared --enable-static"
fi

info "libpng: ./configure $ARGS"
./configure $ARGS || error "configure failed"
$MAKE -j$NJOBS install || error "make install failed"

if [ $BUILD_TEST -eq 1 ]; then
    $MAKE test || error "test failed"   # very slow
fi
