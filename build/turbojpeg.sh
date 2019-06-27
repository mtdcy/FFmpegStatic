#!/bin/bash
#
# 

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://downloads.sourceforge.net/project/libjpeg-turbo/2.0.2/libjpeg-turbo-2.0.2.tar.gz
sha256=acb8599fe5399af114287ee5907aea4456f8f2c1cc96d26c28aebfdf5ee82fed

prepare_pkg_source $url $sha256 $SOURCE/packages/`basename $url` && cd libjpeg-*/

ARGS="-DREQUIRE_SIMD=TRUE -DWITH_JPEG8=1"
ARGS+=" -DCMAKE_MAKE_PROGRAM=$MAKE" # CMAKE_MAKE_PROGRAM can NOT poplute by $MAKE
if [ $BUILD_SHARED -eq 1 ]; then
    ARGS+=" -DENABLE_SHARED=TRUE -DENABLE_STATIC=FALSE"
else
    ARGS+=" -DENABLE_SHARED=FALSE -DENABLE_STATIC=TRUE"
fi

rm -rf build
mkdir build && cd build

cmd="$CMAKE $CMAKE_COMMON_ARGS $ARGS .."
info "libjpeg-turbo: $cmd"
eval $cmd || error "$cmd failed"
$MAKE -j$NJOBS install || error "make install failed" # & test
cd -
