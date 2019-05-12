#!/bin/bash
#
# GPL

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://bitbucket.org/multicoreware/x265/downloads/x265_3.0.tar.gz
sha256=c5b9fc260cabbc4a81561a448f4ce9cad7218272b4011feabc3a6b751b2f0662

function install() {
    ARGS="-DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=Release"
    #ARGS+=" -DLINKED_10BIT=ON -DLINKED_12BIT=ON -DEXTRA_LINK_FLAGS=-L. -DEXTRA_LIB=x265_main10.a;x265_main12.a"
    #ARGS+=" -DHIGH_BIT_DEPTH=ON -DEXPORT_C_API=OFF -DENABLE_CLI=OFF"
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" -DENABLE_SHARED=ON"
    else
        ARGS+=" -DENABLE_SHARED=OFF"
    fi
    cmake $ARGS source || return 
    make -j$NJOBS || return 1
    make install || return 1
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd x265_3.0 &&
install || { error "build x265 failed"; exit 1; }

