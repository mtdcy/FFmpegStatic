#!/bin/bash
#
# BSD 3-Clause

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

license="BSD"
version=0.1.5
url=https://downloads.sourceforge.net/opencore-amr/opencore-amr-$version.tar.gz
sha256=2c006cb9d5f651bfb5e60156dbff6af3c9d35c7bbcc9015308c0aff1e14cd341

function install() {
    ARGS="--prefix=$PREFIX --disable-debug --enable-static --enable-amrnb-decoder --enable-amrnb-encoder"
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" --enable-shared"
    else
        ARGS+=" --disable-shared"
    fi

    info "opencore-amr: ./configure $ARGS"
    ./configure $ARGS || return 1
    $MAKE -j$NJOBS install || return 1

    if [ $BUILD_TEST -eq 1 ]; then 
        cat > a.c <<-'EOF'
#include <opencore-amrnb/interf_enc.h>
#include <opencore-amrwb/dec_if.h>
int main(void) {
    Encoder_Interface_init(0);
    D_IF_init();
    return 0;
}
EOF
        $CC $CFLAGS $LDFLAGS a.c -lopencore-amrnb -lopencore-amrwb -o a || return 
        ./a || return
    fi

    sed -i '/opencore-amr:/d' $PREFIX/LIBRARIES.txt || return
    echo "opencore-amr: $version $license" >> $PREFIX/LIBRARIES.txt || return
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd opencore-amr-*/ &&
install || { error "build opencore-amr failed"; exit 1; }
