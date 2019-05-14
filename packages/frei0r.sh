#!/bin/bash
#
# GPL

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://files.dyne.org/frei0r/releases/frei0r-plugins-1.6.1.tar.gz
sha256=e0c24630961195d9bd65aa8d43732469e8248e8918faa942cfb881769d11515e

function install() {
    # alwasy build shared libraries
    # both build system has its faults
    if [[ "$OSTYPE" == "msys" ]]; then
        ARGS="-DCMAKE_INSTALL_PREFIX=$PREFIX"
        ARGS+="-DCMAKE_MAKE_PROGRAM=$MAKE"

        rm -rf build 
        mkdir -p build && cd build 
        info "frei0r: cmake $ARGS .."
        cmake -G"MSYS Makefiles" $ARGS ..
        $MAKE -j$NJOBS install || return
        cd -
    else
        ARGS="--prefix=$PREFIX --disable-debug --enable-shared"
        info "frei0r: ./configure $ARGS"
        ./configure $ARGS || return 1
        $MAKE -j$NJOBS install || return 1
    fi

    sed -i '/frei0r:/d' $PREFIX/LIBRARIES.txt || return
    echo "frei0r: 1.6.1" >> $PREFIX/LIBRARIES.txt || return
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd frei0r*/ &&
install || { error "build frei0r failed"; exit 1; }

