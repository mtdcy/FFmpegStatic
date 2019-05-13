#!/bin/bash
#
# 

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://downloads.sourceforge.net/project/giflib/giflib-5.1.4.tar.bz2
sha256=df27ec3ff24671f80b29e6ab1c4971059c14ac3db95406884fc26574631ba8d5

function install() {
    ARGS="--prefix=$PREFIX --disable-debug --enable-static"
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" --enable-shared"
    else
        ARGS+=" --disable-shared"
    fi

    info "giflib: ./configure $ARGS"
    ./configure $ARGS || return 1
    $MAKE -j$NJOBS || return 1
    if [ $BUILD_TEST -eq 1 ]; then
        $MAKE check || return 1
    fi
    $MAKE install || return 1
    sed -i '/giflib:/d' $PREFIX/LIBRARIES.txt || return
    echo "giflib: 5.1.4" >> $PREFIX/LIBRARIES.txt || return
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd giflib-* &&
install || { error "build png failed"; exit 1; }



