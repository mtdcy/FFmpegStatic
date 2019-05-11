#!/bin/bash
# usage: zlib.sh <install_prefix>

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://ftp.osuosl.org/pub/clfs/conglomeration/bzip2/bzip2-1.0.6.tar.gz
sha256=a2848f34fcd5d6cf47def00461fcb528a0484d8edef8208d6d2e2909dc61d9cd

function install() {
    sed -i '/CC=gcc/d' Makefile
    sed -i '/AR=ar/d' Makefile
    sed -i '/RANLIB=ranlib/d' Makefile
    sed -i '/LDFLAGS=/d' Makefile
    make -j$NJOBS || return 1
    make install PREFIX=$PREFIX || return 1
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd bzip2-1.0.6 &&
install || { error "build bzip2 failed"; exit 1; }

