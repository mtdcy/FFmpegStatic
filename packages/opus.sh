#!/bin/bash
#
# BSD 3-Clause

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

license="BSD"
version=1.3.1
url=https://archive.mozilla.org/pub/opus/opus-$version.tar.gz
sha256=65b58e1e25b2a114157014736a3d9dfeaad8d41be1c8179866f144a2fb44ff9d

function install() {
    ARGS="--prefix=$PREFIX --disable-debug --enable-static --disable-extra-programs"
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" --enable-shared"
    else
        ARGS+=" --disable-shared"
    fi

    info "opus: ./configure $ARGS"
    ./configure $ARGS || return 1
    $MAKE -j$NJOBS install || return 1

    if [ $BUILD_TEST -eq 1 ]; then 
        $MAKE check || return 1
        cat > a.c <<-'EOF'
#include <opus/opus.h>
int main(void) {
    opus_encoder_get_size(1);
    return 0;
}
EOF
        $CC $CFLAGS $LDFLAGS a.c -lopus -o a || return
        ./a || return
    fi

    sed -i '/opus:/d' $PREFIX/LIBRARIES.txt || return
    echo "opus: $version $license" >> $PREFIX/LIBRARIES.txt || return
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd opus-*/ &&
install || { error "build libogg failed"; exit 1; }



