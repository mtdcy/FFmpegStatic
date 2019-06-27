#!/bin/bash
#
# BSD 3-Clause

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

license="BSD"
version=1.3.6
url=https://downloads.xiph.org/releases/vorbis/libvorbis-$version.tar.xz
sha256=af00bb5a784e7c9e69f56823de4637c350643deedaf333d0fa86ecdba6fcb415

prepare_pkg_source $url $sha256 $SOURCE/packages/`basename $url` && cd libvorbis-*/

ARGS="--prefix=$PREFIX --disable-debug"
if [ $BUILD_SHARED -eq 1 ]; then
    ARGS+=" --enable-shared --disable-static"
else
    ARGS+=" --disable-shared --enable-static"
fi

info "libvorbis: ./configure $ARGS"
./configure $ARGS || error "configure failed"
$MAKE -j$NJOBS install || error "make install failed"

if [ $BUILD_TEST -eq 1 ]; then 
    $MAKE check || error "check failed"
fi
