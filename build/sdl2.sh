#!/bin/bash
# usage: sdl2.sh <install_prefix>

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

license=""
version=2.0.9
url=https://libsdl.org/release/SDL2-$version.tar.gz
sha256=255186dc676ecd0c1dbf10ec8a2cc5d6869b5079d8a38194c2aecdff54b324b1

prepare_pkg_source $url $sha256 $SOURCE/packages/`basename $url` && cd SDL2-*/

ARGS="--prefix=$PREFIX --without-x"

if [ $BUILD_SHARED -eq 1 ]; then
    ARGS+=" --enable-shared --disable-static --enable-rpath"
else
    ARGS+=" --disable-shared --enable-static"
fi

cmd="./configure $ARGS"
info "sdl2: $cmd"
eval $cmd || error "$cmd failed"

$MAKE -j$NJOBS install || error "sdl2: install failed"
