#!/bin/bash
#
# BSD

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://github.com/cisco/openh264/archive/v1.8.0.tar.gz
sha256=08670017fd0bb36594f14197f60bebea27b895511251c7c64df6cd33fc667d34

prepare_pkg_source $url $sha256 $SOURCE/packages/openh264-`basename $url` && cd openh264-*/

# remove default value, using env instead
info "openh264: $MAKE ..."
sed -i '/^PREFIX=*/d' Makefile 

if [[ "$OSTYPE" == "msys" ]]; then
    sed -i '/^CC =/d' build/platform-mingw_nt.mk
    sed -i '/^CXX =/d' build/platform-mingw_nt.mk
    sed -i '/^AR =/d' build/platform-mingw_nt.mk
fi

if [ $BUILD_SHARED -eq 1 ]; then
    PREFIX=$PREFIX $MAKE -j$NJOBS install-shared || error "make install-shared failed"
else
    PREFIX=$PREFIX $MAKE -j$NJOBS install-static || error "make install-static failed"
fi
