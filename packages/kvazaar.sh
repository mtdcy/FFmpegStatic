#!/bin/bash
#
# LGPL

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://github.com/ultravideo/kvazaar/releases/download/v1.2.0/kvazaar-1.2.0.tar.xz
sha256=9bc9ba4d825b497705bd6d84817933efbee43cbad0ffaac17d4b464e11e73a37

function install() {
    ARGS="--prefix=$PREFIX --disable-debug --enable-static"
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" --enable-shared"
    else
        ARGS+=" --disable-shared"
    fi

    info "kvazaar: ./configure $ARGS"
    ./configure $ARGS || return 1
    $MAKE -j$NJOBS || return 1
    $MAKE install || return 1
    if [ $BUILD_TEST -eq 1 ]; then
        $PREFIX/bin/kvazaar --help || return
    fi
    sed -i '/kvazaar:/d' $PREFIX/LIBRARIES.txt || return
    echo "kvazaar: 1.2.0" >> $PREFIX/LIBRARIES.txt || return
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd kvazaar-* &&
install || { error "build kvazaar failed"; exit 1; }
