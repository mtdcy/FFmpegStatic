#!/bin/bash
#
# GPL

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=ftp://ftp.videolan.org/pub/x264/snapshots/last_x264.tar.bz2
sha256=2c623eb8388df8d9a7962b56e5b02ebf2e55a41f929b928352f95c0385d1a4fa

function install() {
    ARGS="--prefix=$PREFIX --enable-static --enable-asm"
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" --enable-shared"
    fi

    info "x264: ./configure $ARGS"
    AS=$NASM ./configure $ARGS || return 1
    $MAKE -j$NJOBS install || return 1

    if [ $BUILD_TEST -eq 1 ]; then
        cat > test.c <<-'EOF'
#include <stdint.h>
#include <x264.h>
int main()
{
    x264_picture_t pic;
    x264_picture_init(&pic);
    x264_picture_alloc(&pic, 1, 1, 1);
    x264_picture_clean(&pic);
    return 0;
}
EOF
        $CC $CFLAGS $LDFLAGS test.c -lx264 -o test || return 
        ./test || return
        $PREFIX/bin/x264 -V || return
    fi
    sed -i '/x264:/d' $PREFIX/LIBRARIES.txt || return
    echo "x264: HEAD" >> $PREFIX/LIBRARIES.txt || return
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd x264-* &&
install || { error "build x264 failed"; exit 1; }

