#!/bin/bash
#
# BSD 3-Clause

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

license="BSD"
version=0.1.5
url=https://downloads.sourceforge.net/opencore-amr/opencore-amr-$version.tar.gz
sha256=2c006cb9d5f651bfb5e60156dbff6af3c9d35c7bbcc9015308c0aff1e14cd341

prepare_pkg_source $url $sha256 $SOURCE/packages/`basename $url` && cd opencore-amr-*/

ARGS="--prefix=$PREFIX --disable-debug --enable-amrnb-decoder --enable-amrnb-encoder"
if [ $BUILD_SHARED -eq 1 ]; then
    ARGS+=" --enable-shared --disable-static"
else
    ARGS+=" --disable-shared --enable-static"
fi

info "opencore-amr: ./configure $ARGS"
./configure $ARGS || error "configure failed"
$MAKE -j$NJOBS install || error "make install failed"
