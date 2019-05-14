#!/bin/bash
#
# MIT

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

license="MIT"
version=2.9.9
url=http://xmlsoft.org/sources/libxml2-$version.tar.gz
sha256=94fb70890143e3c6549f265cee93ec064c80a84c42ad0f23e85ee1fd6540a871

function install() {
    ARGS="--prefix=$PREFIX --disable-debug --enable-static --without-python"
    ARGS+=" --with-zlib=$PREFIX --with-lzma=$PREFIX --with-iconv=$PREFIX"
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" --enable-shared"
    else
        ARGS+=" --disable-shared"
    fi

    info "libxml2: ./configure $ARGS"
    ./configure $ARGS || return 1
    $MAKE -j$NJOBS install || return 1

    if [ $BUILD_TEST -eq 1 ]; then
        # test failed in MSYS2
        if [[ "$OSTYPE" != "msys" ]]; then
            $MAKE check || return
        fi

        cat > a.c <<-'EOF'
#include <libxml/xmlversion.h>
int main(void) {
    xmlCheckVersion(0);
    return 0;
}
EOF
        $CC $CFLAGS $LDFLAGS -I$PREFIX/include/libxml2 a.c -lz -llzma -liconv -lxml2 -o a || return
        ./a || return
    fi

    sed -i '/libxml2:/d' $PREFIX/LIBRARIES.txt || return
    echo "libxml2: $version $license" >> $PREFIX/LIBRARIES.txt || return
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd libxml2-*/ &&
install || { error "build libxml2 failed"; exit 1; }


