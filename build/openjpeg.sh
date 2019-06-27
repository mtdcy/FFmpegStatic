#!/bin/bash
#
# 

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://github.com/uclouvain/openjpeg/archive/v2.3.1.tar.gz
sha256=63f5a4713ecafc86de51bfad89cc07bb788e9bba24ebbf0c4ca637621aadb6a9

prepare_pkg_source $url $sha256 $SOURCE/packages/openjpeg-`basename $url` && cd openjpeg-*/

ARGS="-DCMAKE_MAKE_PROGRAM=$MAKE" # CMAKE_MAKE_PROGRAM can NOT poplute by $MAKE
if [ $BUILD_SHARED -eq 1 ]; then
    ARGS+=" -DBUILD_SHARED_LIBS=ON -DBUILD_STATIC_LIBS=OFF"
else
    ARGS+=" -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON"
    # no applications
    ARGS+=" -DBUILD_CODEC=OFF"
fi

rm -rf tmp
mkdir -p tmp && cd tmp

cmd="$CMAKE $CMAKE_COMMON_ARGS $ARGS .."
info "openjpeg: $cmd"
eval $cmd || error "$cmd failed"
$MAKE -j$NJOBS install || error "make install failed"
cd -
