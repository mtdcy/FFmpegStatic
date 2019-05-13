#!/bin/bash
#
# BSD 3-Clause

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://downloads.sourceforge.net/opencore-amr/opencore-amr-0.1.5.tar.gz
sha256=2c006cb9d5f651bfb5e60156dbff6af3c9d35c7bbcc9015308c0aff1e14cd341

function install() {
    ARGS="--prefix=$PREFIX --disable-debug --enable-static --enable-amrnb-decoder --enable-amrnb-encoder --enable-examples"
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" --enable-shared"
    else
        ARGS+=" --disable-shared"
    fi

    info "opencore-amr: ./configure $ARGS"
    ./configure $ARGS || return 1
    $MAKE -j$NJOBS || return 1
    $MAKE install || return 1
    sed -i '/opencore-amr:/d' $PREFIX/LIBRARIES.txt || return
    echo "opencore-amr: 0.1.5" >> $PREFIX/LIBRARIES.txt || return
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd opencore-amr-* &&
install || { error "build opencore-amr failed"; exit 1; }
