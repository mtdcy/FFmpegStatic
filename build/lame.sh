#!/bin/bash
# usage: lame.sh <install_prefix>
# 
# License: LGPL

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

license="LGPL"
version=3.100
url=https://sourceforge.net/projects/lame/files/lame/$version/lame-$version.tar.gz
sha256=ddfe36cab873794038ae2c1210557ad34857a4b6bdc515785d1da9e175b1da1e

prepare_pkg_source $url $sha256 $SOURCE/packages/`basename $url` && cd lame-*/

# Fix undefined symbol error _lame_init_old
# https://sourceforge.net/p/lame/mailman/message/36081038/
sed -i '/lame_init_old/d' include/libmp3lame.sym

ARGS="--prefix=$PREFIX --disable-debug --disable-frontend --enable-nasm"
if [ $BUILD_SHARED -eq 1 ]; then
    ARGS+=" --enable-shared --disable-static"
else
    ARGS+=" --disable-shared --enable-static"
fi

info "lame: ./configure $ARGS"
./configure $ARGS || error "configure failed"
$MAKE -j$NJOBS install || error "make install failed"

if [ $BUILD_TEST -eq 1 ]; then
    $MAKE test || error "test failed"
fi
