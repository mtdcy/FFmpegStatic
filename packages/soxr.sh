#!/bin/bash
# 
# LGPL
# 

env 

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://downloads.sourceforge.net/project/soxr/soxr-0.1.3-Source.tar.xz
sha256=b111c15fdc8c029989330ff559184198c161100a59312f5dc19ddeb9b5a15889

function install() {
    ARGS="-DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=Release -DWITH_OPENMP=OFF"
    ARGS+=" -DCMAKE_MAKE_PROGRAM=$MAKE" # CMAKE_MAKE_PROGRAM can NOT poplute by $MAKE
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" -DBUILD_SHARED_LIBS=ON"
    else
        ARGS+=" -DBUILD_SHARED_LIBS=OFF"
    fi
    rm -rf build && mkdir build && cd build
    cmake $ARGS .. || return 1
    make -j$NJOBS || return 1
    if [ $BUILD_TEST -eq 1 ]; then 
        make test || return 1
    fi
    make install || return 1
    cd -
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd soxr-0.1.3-Source &&
install || { error "build libsoxr failed"; exit 1; }

