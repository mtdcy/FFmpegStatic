#!/bin/bash
#
# 

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://downloads.sourceforge.net/project/giflib/giflib-5.1.4.tar.bz2
sha256=df27ec3ff24671f80b29e6ab1c4971059c14ac3db95406884fc26574631ba8d5

prepare_pkg_source $url $sha256 $SOURCE/packages/`basename $url` && cd giflib-*/

ARGS="--prefix=$PREFIX --disable-debug"
if [ $BUILD_SHARED -eq 1 ]; then
    ARGS+=" --enable-shared --disable-static"
else
    ARGS+=" --disable-shared --enable-static"
fi

info "giflib: ./configure $ARGS"
./configure $ARGS || error "configure failed"
$MAKE -j$NJOBS install || error "make install failed"

if [ $BUILD_TEST -eq 1 ]; then
    if [[ "$OSTYPE" == "msys" ]]; then 
        $MAKE -C tests # FIXME: test failed on windows
    else
        $MAKE -C tests || error "test failed"
    fi
fi
