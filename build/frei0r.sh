#!/bin/bash
#
# GPL

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://files.dyne.org/frei0r/releases/frei0r-plugins-1.6.1.tar.gz
sha256=e0c24630961195d9bd65aa8d43732469e8248e8918faa942cfb881769d11515e

prepare_pkg_source $url $sha256 $SOURCE/packages/`basename $url` && cd frei0r-*/

# alwasy build shared libraries
# both build system has its faults
if [[ "$OSTYPE" == "msys" ]]; then
    ARGS="-DCMAKE_INSTALL_PREFIX=$PREFIX"
    ARGS+=" -DCMAKE_MAKE_PROGRAM=$MAKE"

    rm -rf build 
    mkdir -p build && cd build 
    cmd="$CMAKE $CMAKE_COMMON_ARGS $ARGS .."
    info "frei0r: $cmd"
    eval $cmd || error "$cmd failed"
    $MAKE -j$NJOBS install || error "make install failed"
    cd -
else
    ARGS="--prefix=$PREFIX --disable-debug --enable-shared"
    info "frei0r: ./configure $ARGS"
    ./configure $ARGS || error "configure failed"
    $MAKE -j$NJOBS install || error "make install failed"
fi
