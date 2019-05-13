#!/bin/bash
# 

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://tukaani.org/xz/xz-5.2.4.tar.bz2
sha256=3313fd2a95f43d88e44264e6b015e7d03053e681860b0d5d3f9baca79c57b7bf

function install() {
    ARGS="--prefix=$PREFIX --disable-debug --enable-static"
    # there is a option about iconv, but no code use it
    #ARGS+=" --with-libiconv-prefix=$PREFIX"
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" --enable-shared"
    else
        ARGS+=" --disable-shared"
    fi

    info "xz: ./configure $ARGS"
    ./configure $ARGS || return 1
    $MAKE clean
    $MAKE -j$NJOBS install || return 1

    if [ $BUILD_TEST -eq 1 ]; then
       $MAKE check || return 1
    fi
    sed -i '/xz:/d' $PREFIX/LIBRARIES.txt || return
    echo "xz: 5.2.4" >> $PREFIX/LIBRARIES.txt || return
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd xz-*/ &&
install || { error "build lzma failed"; exit 1; }

