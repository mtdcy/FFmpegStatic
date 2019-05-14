#!/bin/bash
# usage: lame.sh <install_prefix>
# 
# License: LGPL

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

license="LGPL"
version=3.100
url=https://sourceforge.net/projects/lame/files/lame/$version/lame-$version.tar.gz
sha256=ddfe36cab873794038ae2c1210557ad34857a4b6bdc515785d1da9e175b1da1e

function install() {
    # Fix undefined symbol error _lame_init_old
    # https://sourceforge.net/p/lame/mailman/message/36081038/
    sed -i '/lame_init_old/d' include/libmp3lame.sym

    ARGS="--prefix=$PREFIX --disable-debug --disable-frontend --enable-nasm --enable-static"
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" --enable-shared"
    else
        ARGS+=" --disable-shared"
    fi

    info "lame: ./configure $ARGS"
    ./configure $ARGS || return 1
    $MAKE -j$NJOBS install || return 1

    if [ $BUILD_TEST -eq 1 ]; then
        $MAKE test || return 1
        cat > a.c <<-'EOF'
#include <lame/lame.h>
int main(void) {
    lame_init();
    return 0;
}
EOF
        $CC $CFLAGS $LDFLAGS a.c -lmp3lame -o a || return
        ./a || return
    fi

    sed -i '/lame:/d' $PREFIX/LIBRARIES.txt || return
    echo "lame: $version $license" >> $PREFIX/LIBRARIES.txt || return
}

download $url $sha256 `basename $url` &&
extract `basename $url` &&
cd lame-*/ && 
install || { error "build lame failed"; exit 1; }

