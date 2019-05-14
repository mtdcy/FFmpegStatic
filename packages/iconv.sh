#!/bin/bash
# 

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

license="LGPL"
version=1.15
url=https://ftp.gnu.org/pub/gnu/libiconv/libiconv-$version.tar.gz
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
    $MAKE -j$NJOBS install-lib || return 1
    $MAKE -j$NJOBS install-lib -C libcharset || return 1

    if [ $BUILD_TEST -eq 1 ]; then 
        make check || return

        cat > test.c <<-'EOF'
#include <iconv.h>
int main(void) {
    iconv_t conv = iconv_open("UTF-8","GB18030");
    return 0;
}
EOF
        $CC $CFLAGS $LDFLAGS test.c -liconv -o out || return
        ./out || return
    fi

    sed -i '/libiconv:/d' $PREFIX/LIBRARIES.txt || return
    echo "libiconv: $version $license" >> $PREFIX/LIBRARIES.txt || return
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd libiconv-*/ &&
install || { error "build iconv failed"; exit 1; }

