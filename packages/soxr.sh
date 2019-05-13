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

    info "soxr: cmake $ARGS .."
    cmake $ARGS .. || return 1
    $MAKE -j$NJOBS || return 1
    if [ $BUILD_TEST -eq 1 ]; then 
        $MAKE test || return 1
    fi
    $MAKE install || return 1
    cd -
    sed -i '/soxr:/d' $PREFIX/LIBRARIES.txt || return
    echo "soxr: 0.1.3" >> $PREFIX/LIBRARIES.txt || return
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd soxr-* &&
install || { error "build libsoxr failed"; exit 1; }

