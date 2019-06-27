#!/bin/bash
# usage: zlib.sh <install_prefix>

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

license="zlib"
version=1.2.11
url=https://zlib.net/zlib-$version.tar.gz
sha256=c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1

prepare_pkg_source $url $sha256 $SOURCE/packages/`basename $url` && cd zlib-*/

if [[ "$OSTYPE" == "msys" ]]; then
    # always static 
    sed -i '/CC = /d' win32/Makefile.gcc
    sed -i '/AS = /d' win32/Makefile.gcc
    sed -i '/LD = /d' win32/Makefile.gcc 
    ENV="LOC=\"$CFLAGS\" INCLUDE_PATH=$PREFIX/include LIBRARY_PATH=$PREFIX/lib BINARY_PATH=$PREFIX/bin"
    info "$MAKE -j$NJOBS install -f win32/Makefile.gcc $ENV"
    $MAKE -j$NJOBS install -f win32/Makefile.gcc $ENV
    if [ $BUILD_SHARED -eq 1 ]; then
        cp libz.dll.a $PREFIX/lib
        cp zlib1.dll $PREFIX/bin
    fi
else
    ARGS="--prefix=$PREFIX"
    if [ $BUILD_SHARED -eq 0 ]; then
        ARGS+=" --static"
    fi
    info "zlib: ./configure $ARGS"
    ./configure $ARGS || error "configure failed"
    $MAKE -j$NJOBS install || error "make install failed"
fi

if [ $BUILD_TEST -eq 1 ]; then 
    $MAKE test || error "test failed"
fi
