#!/bin/bash
# usage: zlib.sh <install_prefix>

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://tukaani.org/xz/xz-5.2.4.tar.bz2
sha256=3313fd2a95f43d88e44264e6b015e7d03053e681860b0d5d3f9baca79c57b7bf

function install() {
    ARGS="--prefix=$PREFIX --disable-debug --enable-static"
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" --enable-shared"
    else
        ARGS+=" --disable-shared"
    fi

    info "xz: ./configure $ARGS"
    ./configure $ARGS || return 1
    $MAKE clean
    $MAKE -j$NJOBS || return 1
    if [ $BUILD_TEST -eq 1 ]; then
       $MAKE check || return 1
    fi
    $MAKE install || return 1
    sed -i '/xz:/d' $PREFIX/LIBRARIES.txt || return
    echo "xz: 5.2.4" >> $PREFIX/LIBRARIES.txt || return
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd xz-5.2.4 &&
install || { error "build lzma failed"; exit 1; }

