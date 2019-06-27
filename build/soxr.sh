#!/bin/bash
# 
# LGPL
# 

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

license="LGPL"
version=0.1.3
url=https://downloads.sourceforge.net/project/soxr/soxr-$version-Source.tar.xz
sha256=b111c15fdc8c029989330ff559184198c161100a59312f5dc19ddeb9b5a15889

prepare_pkg_source $url $sha256 $SOURCE/packages/`basename $url` && cd soxr-*/

ARGS="-DWITH_OPENMP=OFF"
ARGS+=" -DCMAKE_MAKE_PROGRAM=$MAKE" # CMAKE_MAKE_PROGRAM can NOT polute by $MAKE
if [ $BUILD_SHARED -eq 1 ]; then
    ARGS+=" -DBUILD_SHARED_LIBS=ON"
else
    ARGS+=" -DBUILD_SHARED_LIBS=OFF"
fi
rm -rf build && mkdir build && cd build

cmd="$CMAKE $CMAKE_COMMON_ARGS $ARGS .."
info "soxr: $cmd"
eval $cmd || error "$cmd failed"
$MAKE -j$NJOBS install || error "make install failed"

if [ $BUILD_TEST -eq 1 ]; then 
    $MAKE test || error "test failed"
fi

cd -
