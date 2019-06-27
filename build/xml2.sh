#!/bin/bash
#
# MIT

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

license="MIT"
version=2.9.9
url=http://xmlsoft.org/sources/libxml2-$version.tar.gz
sha256=94fb70890143e3c6549f265cee93ec064c80a84c42ad0f23e85ee1fd6540a871

prepare_pkg_source $url $sha256 $SOURCE/packages/`basename $url` && cd libxml2-*/

ARGS="--prefix=$PREFIX --disable-debug --without-python"
ARGS+=" --with-zlib=$PREFIX --with-lzma=$PREFIX --with-iconv=$PREFIX"
if [ $BUILD_SHARED -eq 1 ]; then
    ARGS+=" --enable-shared --disable-static"
else
    ARGS+=" --disable-shared --enable-static"
fi

info "libxml2: ./configure $ARGS"
./configure $ARGS || error "configure failed"
$MAKE -j$NJOBS install || error "make install failed"

if [ $BUILD_TEST -eq 1 ]; then
    # test failed in MSYS2
    if [[ "$OSTYPE" != "msys" ]]; then
        $MAKE check || error "check failed"
    fi
fi
