#!/bin/bash
#
# LGPL 2.1 
# for libass

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://github.com/fribidi/fribidi/releases/download/v1.0.5/fribidi-1.0.5.tar.bz2
sha256=6a64f2a687f5c4f203a46fa659f43dd43d1f8b845df8d723107e8a7e6158e4ce

function install() {
    ARGS="--prefix=$PREFIX --disable-debug --enable-static"
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" --enable-shared"
    else
        ARGS+=" --disable-shared"
    fi

    info "fribidi: ./configure $ARGS"
    ./configure $ARGS || return 1
    $MAKE -j$NJOBS || return 1
    $MAKE install || return 1
    sed -i '/fribidi:/d' $PREFIX/LIBRARIES.txt || return
    echo "fribidi: 1.0.5" >> $PREFIX/LIBRARIES.txt || return
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd fribidi-1.0.5 &&
install || { error "build fribidi failed"; exit 1; }

