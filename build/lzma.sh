#!/bin/bash
# 

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

license=""
version=5.2.4
url=https://tukaani.org/xz/xz-$version.tar.bz2
sha256=3313fd2a95f43d88e44264e6b015e7d03053e681860b0d5d3f9baca79c57b7bf

prepare_pkg_source $url $sha256 $SOURCE/packages/`basename $url` && cd xz-*/

ARGS="--prefix=$PREFIX --disable-debug"
if [ $BUILD_SHARED -eq 1 ]; then
    ARGS+=" --enable-shared --disable-static"
else
    ARGS+=" --disable-shared --enable-static"
fi

info "xz: ./configure $ARGS"
./configure $ARGS || error "configure failed"
$MAKE -j$NJOBS install || error "make install failed"

if [ $BUILD_TEST -eq 1 ]; then
    $MAKE check || error "check failed"
fi
