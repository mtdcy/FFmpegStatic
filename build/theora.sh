#!/bin/bash
#
# BSD 3-Clause

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.bz2
sha256=b6ae1ee2fa3d42ac489287d3ec34c5885730b1296f0801ae577a35193d3affbc

prepare_pkg_source $url $sha256 $SOURCE/packages/`basename $url` && cd libtheora-*/

ARGS="--prefix=$PREFIX --disable-debug"
# theora is in bad structure, these targets may failed
ARGS+=" --disable-examples --disable-oggtest --disable-vorbistest"
ARGS+=" --with-ogg=$PREFIX --with-vorbis=$PREFIX"
if [ $BUILD_SHARED -eq 1 ]; then
    ARGS+=" --enable-shared --disable-static"
else
    ARGS+=" --disable-shared --enable-static"
fi

info "libtheora: ./configure $ARGS"
./configure $ARGS || error "configure failed"
$MAKE -j$NJOBS install || error "make install failed"

if [ $BUILD_TEST -eq 1 ]; then 
    $MAKE check || error "check failed"
fi
