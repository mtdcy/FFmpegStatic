#!/bin/bash
#
# BSD 3-Clause

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

license="BSD"
version=1.3.3
url=https://downloads.xiph.org/releases/ogg/libogg-$version.tar.gz
sha256=c2e8a485110b97550f453226ec644ebac6cb29d1caef2902c007edab4308d985

prepare_pkg_source $url $sha256 $SOURCE/packages/`basename $url` && cd libogg-*/

ARGS="--prefix=$PREFIX --disable-debug"
if [ $BUILD_SHARED -eq 1 ]; then
    ARGS+=" --enable-shared --disable-static"
else
    ARGS+=" --disable-shared --enable-static"
fi

info "libogg: ./configure $ARGS"
./configure $ARGS || error "configure failed"
$MAKE -j$NJOBS install || error "make install failed"

if [ $BUILD_TEST -eq 1 ]; then
    $MAKE check || error "check failed"
fi
