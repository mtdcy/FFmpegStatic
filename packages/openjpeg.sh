#!/bin/bash
#
# 

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://github.com/uclouvain/openjpeg/archive/v2.3.1.tar.gz
sha256=63f5a4713ecafc86de51bfad89cc07bb788e9bba24ebbf0c4ca637621aadb6a9

function install() {
    ARGS="-DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=Release -DBUILD_STATIC_LIBS=ON"
    ARGS+=" -DCMAKE_MAKE_PROGRAM=$MAKE" # CMAKE_MAKE_PROGRAM can NOT poplute by $MAKE
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" -DBUILD_SHARED_LIBS=ON"
    else
        ARGS+=" -DBUILD_SHARED_LIBS=OFF"
    fi
    rm -rf build && mkdir build && cd build
    cmake $ARGS .. || return 1
    make -j$NJOBS || return 1
    make install || return 1
    cd -
}

download $url $sha256 openjpeg-`basename $url` &&
extract openjpeg-`basename $url` && 
cd openjpeg-2.3.1 &&
install || { error "build openjpeg failed"; exit 1; }



