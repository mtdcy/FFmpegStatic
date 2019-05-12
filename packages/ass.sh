#!/bin/bash
# usage: libass.sh <install_prefix>
#
# LICENSE: ISC (BSD 2-Clause)

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://github.com/libass/libass/releases/download/0.14.0/libass-0.14.0.tar.xz
sha256=881f2382af48aead75b7a0e02e65d88c5ebd369fe46bc77d9270a94aa8fd38a2

function install() {
    ARGS="--prefix=$PREFIX --disable-debug --disable-fontconfig"
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" --enable-shared"
    else
        ARGS+=" --disable-shared"
    fi

    info "libass: ./configure $ARGS"
    ./configure $ARGS || return 1
    $MAKE -j$NJOBS || return 1
    $MAKE install || return 1
    sed -i '/libass:/d' $PREFIX/LIBRARIES.txt || return
    echo "libass: 0.14.0" >> $PREFIX/LIBRARIES.txt || return
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd libass-0.14.0 &&
install || { error "build libass failed"; exit 1; }

