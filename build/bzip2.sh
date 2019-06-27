#!/bin/bash
# usage: zlib.sh <install_prefix>

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

license=""
version=1.0.6
url=https://ftp.osuosl.org/pub/clfs/conglomeration/bzip2/bzip2-$version.tar.gz
sha256=a2848f34fcd5d6cf47def00461fcb528a0484d8edef8208d6d2e2909dc61d9cd

prepare_pkg_source $url $sha256 $SOURCE/packages/`basename $url` && cd bzip2-*/

sed -i '/CC=gcc/d' Makefile
sed -i '/AR=ar/d' Makefile
sed -i '/RANLIB=ranlib/d' Makefile
sed -i '/LDFLAGS=/d' Makefile
sed -i 's/CFLAGS=/CFLAGS+=/g' Makefile

info "bzip2: $MAKE -j$NJOBS install"
$MAKE -j$NJOBS install PREFIX=$PREFIX || error "make install failed"

if [ $BUILD_TEST -eq 1 ]; then 
    $MAKE test || error "test failed"
fi
