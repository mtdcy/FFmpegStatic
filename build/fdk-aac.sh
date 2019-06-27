#!/bin/bash
#
# BSD 3-Clause

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

license="BSD"
version=2.0.0
url=https://downloads.sourceforge.net/project/opencore-amr/fdk-aac/fdk-aac-$version.tar.gz
sha256=f7d6e60f978ff1db952f7d5c3e96751816f5aef238ecf1d876972697b85fd96c

prepare_pkg_source $url $sha256 $SOURCE/packages/`basename $url` && cd fdk-aac-*/

ARGS="--prefix=$PREFIX --disable-debug"
if [ $BUILD_SHARED -eq 1 ]; then
    ARGS+=" --enable-shared --disable-static"
else
    ARGS+=" --disable-shared --enable-static"
fi
info "fdk-aac: ./configure $ARGS"
./configure $ARGS || error "configure failed"
$MAKE -j$NJOBS install || error "make install failed"

if [ $BUILD_TEST -eq 1 ]; then
    $MAKE check || error "check failed"
fi
