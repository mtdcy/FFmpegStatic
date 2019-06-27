#!/bin/bash
# 

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

license="LGPL"
version=1.15
url=https://ftp.gnu.org/pub/gnu/libiconv/libiconv-$version.tar.gz
sha256=ccf536620a45458d26ba83887a983b96827001e92a13847b45e4925cc8913178

prepare_pkg_source $url $sha256 $SOURCE/packages/`basename $url` && cd libiconv-*/

ARGS="--prefix=$PREFIX --disable-debug --enable-extra-encodings"
if [ $BUILD_SHARED -eq 1 ]; then
    ARGS+=" --enable-shared --disable-static"
else
    ARGS+=" --disable-shared --enable-static"
fi

info "libiconv: ./configure $ARGS"
./configure $ARGS || error "configure failed"
$MAKE -j$NJOBS install-lib || error "install failed"
$MAKE -j$NJOBS install-lib -C libcharset || error "install libcharset failed"

if [ $BUILD_TEST -eq 1 ]; then 
    make check || error "check failed"
fi
