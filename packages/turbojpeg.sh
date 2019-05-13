#!/bin/bash
#
# 

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://downloads.sourceforge.net/project/libjpeg-turbo/2.0.2/libjpeg-turbo-2.0.2.tar.gz
sha256=acb8599fe5399af114287ee5907aea4456f8f2c1cc96d26c28aebfdf5ee82fed

function install() {
    ARGS="-DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=Release"
    ARGS+=" -DCMAKE_MAKE_PROGRAM=$MAKE" # CMAKE_MAKE_PROGRAM can NOT poplute by $MAKE
    ARGS+=" -DENABLE_STATIC=TRUE -DREQUIRE_SIMD=TRUE -DWITH_JPEG8=1"
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" -DENABLE_SHARED=TRUE"
    else
        ARGS+=" -DENABLE_SHARED=FALSE"
    fi

    rm -rf build
    mkdir build && cd build

    info "libjpeg-turbo: cmake $ARGS .."
    if [[ "$OSTYPE" == "msys" ]]; then
        cmake -G"MSYS Makefiles" $ARGS .. || return
    else
        cmake $ARGS .. || return 1
    fi
    $MAKE -j$NJOBS install || return 1 # & test
    cd -

    sed -i '/libjpeg-turbo:/d' $PREFIX/LIBRARIES.txt || return
    echo "libjpeg-turbo: 2.0.2" >> $PREFIX/LIBRARIES.txt || return
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd libjpeg-turbo-*/ &&
install || { error "build jpeg failed"; exit 1; }


