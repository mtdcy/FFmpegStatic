#!/bin/bash
# usage: zlib.sh <install_prefix>

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.15.tar.gz
sha256=ccf536620a45458d26ba83887a983b96827001e92a13847b45e4925cc8913178

function install() {
    ARGS="--prefix=$PREFIX --disable-debug --enable-extra-encodings --enable-static"
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" --enable-shared"
    else
        ARGS+=" --disable-shared"
    fi

    info "libiconv: ./configure $ARGS"
    ./configure $ARGS || return 1
    $MAKE -j$NJOBS || return 1
    $MAKE install || return 1
    sed -i '/libiconv:/d' $PREFIX/LIBRARIES.txt || return
    echo "libiconv: 1.15" >> $PREFIX/LIBRARIES.txt || return
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd libiconv-1.15 &&
install || { error "build iconv failed"; exit 1; }

