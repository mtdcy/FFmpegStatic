#!/bin/bash
#
# BSD 3-Clause

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

license="BSD"
version=2.0.0
url=https://downloads.sourceforge.net/project/opencore-amr/fdk-aac/fdk-aac-$version.tar.gz
sha256=f7d6e60f978ff1db952f7d5c3e96751816f5aef238ecf1d876972697b85fd96c

function install() {
    ARGS="--prefix=$PREFIX --disable-debug --enable-static"
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" --enable-shared"
    else
        ARGS+=" --disable-shared"
    fi
    info "fdk-aac: ./configure $ARGS"
    ./configure $ARGS || return 1
    $MAKE -j$NJOBS install || return 1

    if [ $BUILD_TEST -eq 1 ]; then
        $MAKE check || return 1
        cat > a.c <<-'EOF'
#include <fdk-aac/aacdecoder_lib.h>
int main(void) {
    LIB_INFO li;
    aacDecoder_GetLibInfo(&li);
    return 0;
}
EOF
        $CC $CFLAGS $LDFLAGS a.c -lfdk-aac -o a || return
        ./a || return
    fi

    sed -i '/fdk-aac:/d' $PREFIX/LIBRARIES.txt || return
    echo "fdk-aac: $version $license" >> $PREFIX/LIBRARIES.txt  || return
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd fdk-aac-*/ &&
install || { error "build fdk-aac failed"; exit 1; }
