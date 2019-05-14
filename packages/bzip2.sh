#!/bin/bash
# usage: zlib.sh <install_prefix>

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

license=""
version=1.0.6
url=https://ftp.osuosl.org/pub/clfs/conglomeration/bzip2/bzip2-$version.tar.gz
sha256=a2848f34fcd5d6cf47def00461fcb528a0484d8edef8208d6d2e2909dc61d9cd

function install() {
    sed -i '/CC=gcc/d' Makefile
    sed -i '/AR=ar/d' Makefile
    sed -i '/RANLIB=ranlib/d' Makefile
    sed -i '/LDFLAGS=/d' Makefile
    sed -i '/PREFIX=/d' Makefile

    info "bzip2: $MAKE -j$NJOBS install"
    $MAKE -j$NJOBS install || return 1

    if [ $BUILD_TEST -eq 1 ]; then 
        $MAKE test || return
        cat > a.c <<-'EOF'
#include <bzlib.h>
int main(void) {
    BZ2_bzlibVersion();
    return 0;
}
EOF
        $CC $CFLAGS $LDFLAGS a.c -lbz2 -o a || return
        ./a || return
    fi

    sed -i '/bzip2:/d' $PREFIX/LIBRARIES.txt || return
    echo "bzip2: $version $license" >> $PREFIX/LIBRARIES.txt || return
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd bzip2-*/ &&
install || { error "build bzip2 failed"; exit 1; }

