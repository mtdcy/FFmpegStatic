#!/bin/bash
#
# BSD 3-Clause

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.bz2
sha256=b6ae1ee2fa3d42ac489287d3ec34c5885730b1296f0801ae577a35193d3affbc

function install() {
    ARGS="--prefix=$PREFIX --disable-debug --enable-static"
    # theora is in bad structure, these targets may failed
    ARGS+=" --disable-examples --disable-oggtest --disable-vorbistest"
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" --enable-shared"
    else
        ARGS+=" --disable-shared"
    fi

    info "libtheora: ./configure $ARGS"
    ./configure $ARGS || return 1
    $MAKE -j$NJOBS || return 1
    if [ $BUILD_TEST -eq 1 ]; then 
        $MAKE check || return 1
    fi
    $MAKE install || return 1
    sed -i '/libtheora:/d' $PREFIX/LIBRARIES.txt || return
    echo "libtheora: 1.1.1" >> $PREFIX/LIBRARIES.txt || return
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd libtheora-1.1.1 &&
install || { error "build theora failed"; exit 1; }

