#!/bin/bash
#
# GPL

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://download.videolan.org/pub/videolan/x264/snapshots/x264-snapshot-20190624-2245-stable.tar.bz2
sha256=f29f6c3114bff735328c0091158ad03ea9f084e1bb943907fd45a8412105e324

prepare_pkg_source $url $sha256 $SOURCE/packages/`basename $url` && cd x264-*/

ARGS="--prefix=$PREFIX --enable-pic"
ARGS+=" --disable-avs --disable-swscale --disable-lavf --disable-ffms --disable-gpac --disable-lsmash"
ARGS+=" --extra-cflags=\"$CFLAGS\" --extra-ldflags=\"$LDFLAGS\""
if [ $BUILD_SHARED -eq 1 ]; then
    ARGS+=" --enable-shared --disable-static --enable-pic"
else
    ARGS+=" --disable-shared --enable-static"
fi

cmd="AS=$NASM ./configure $ARGS"
info "x264: $cmd"
eval $cmd || error "$cmd failed"
$MAKE -j$NJOBS install || error "make install failed"

if [ $BUILD_TEST -eq 1 ]; then
    $PREFIX/bin/x264 -V || error "test failed"
fi
