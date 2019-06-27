#!/bin/bash
#
# LGPL

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://github.com/ultravideo/kvazaar/releases/download/v1.2.0/kvazaar-1.2.0.tar.xz
sha256=9bc9ba4d825b497705bd6d84817933efbee43cbad0ffaac17d4b464e11e73a37

prepare_pkg_source $url $sha256 $SOURCE/packages/`basename $url` && cd kvazaar-*/

ARGS="--prefix=$PREFIX --disable-debug"
if [ $BUILD_SHARED -eq 1 ]; then
    ARGS+=" --enable-shared --disable-static"
else
    ARGS+=" --disable-shared --enable-static"
fi

info "kvazaar: ./configure $ARGS"
./configure $ARGS || error "configure failed"
$MAKE -j$NJOBS install || error "make install failed"

if [ $BUILD_TEST -eq 1 ]; then
    $PREFIX/bin/kvazaar --help || error "test failed"
fi
