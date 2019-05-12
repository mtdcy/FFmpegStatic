#!/bin/bash
#
# BSD 3-Clause

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://downloads.xiph.org/releases/vorbis/libvorbis-1.3.6.tar.xz
sha256=af00bb5a784e7c9e69f56823de4637c350643deedaf333d0fa86ecdba6fcb415

function install() {
    ARGS="--prefix=$PREFIX --disable-debug --enable-static"
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" --enable-shared"
    else
        ARGS+=" --disable-shared"
    fi

    info "libvorbis: ./configure $ARGS"
    ./configure $ARGS || return 1
    $MAKE -j$NJOBS || return 1
    $MAKE install || return 1
    sed -i '/libvorbis:/d' $PREFIX/LIBRARIES.txt || return
    echo "libvorbis: 1.3.6" >> $PREFIX/LIBRARIES.txt || return
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd libvorbis-1.3.6 &&
install || { error "build libvorbis failed"; exit 1; }

