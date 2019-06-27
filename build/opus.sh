#!/bin/bash
#
# BSD 3-Clause

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

license="BSD"
version=1.3.1
url=https://archive.mozilla.org/pub/opus/opus-$version.tar.gz
sha256=65b58e1e25b2a114157014736a3d9dfeaad8d41be1c8179866f144a2fb44ff9d

prepare_pkg_source $url $sha256 $SOURCE/packages/`basename $url` && cd opus-*/

ARGS="--prefix=$PREFIX --disable-debug --disable-extra-programs"
if [ $BUILD_SHARED -eq 1 ]; then
    ARGS+=" --enable-shared --disable-static"
else
    ARGS+=" --disable-shared --enable-static"
fi

info "opus: ./configure $ARGS"
./configure $ARGS || error "configure failed"
$MAKE -j$NJOBS install || error "make install failed"

if [ $BUILD_TEST -eq 1 ]; then 
    $MAKE check || error "check failed"
fi
