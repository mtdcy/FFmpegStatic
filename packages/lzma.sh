#!/bin/bash
# 

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

license=""
version=5.2.4
url=https://tukaani.org/xz/xz-$version.tar.bz2
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
    $MAKE -j$NJOBS install || return 1

    if [ $BUILD_TEST -eq 1 ]; then
       $MAKE check || return 1
       cat > a.c <<-'EOF'
#include <lzma.h>
int main(void) {
    lzma_version_string();
    return 0;
}
EOF
        $CC $CFLAGS $LDFLAGS a.c -llzma -o a || return
        ./a || return
    fi
    sed -i '/xz:/d' $PREFIX/LIBRARIES.txt || return
    echo "xz: $version $license" >> $PREFIX/LIBRARIES.txt || return
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd xz-*/ &&
install || { error "build lzma failed"; exit 1; }

