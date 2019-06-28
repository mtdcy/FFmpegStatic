#!/bin/bash
#
# GPL

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

license="GPL"
version=3.0
url=https://bitbucket.org/multicoreware/x265/downloads/x265_$version.tar.gz
sha256=c5b9fc260cabbc4a81561a448f4ce9cad7218272b4011feabc3a6b751b2f0662

prepare_pkg_source $url $sha256 $SOURCE/packages/`basename $url` && cd x265*/

ARGS=""

HIGH_BIT_ARGS="-DHIGH_BIT_DEPTH=ON -DEXPORT_C_API=OFF -DENABLE_CLI=OFF -DENABLE_SHARED=OFF"

rm -rf tmp
mkdir -p tmp; cd tmp;
mkdir -p 8bit 10bit 12bit

# 12 bit
cd 12bit
cmd="$CMAKE $CMAKE_COMMON_ARGS $ARGS $HIGH_BIT_ARGS -DMAIN12=ON ../../source"
info "x265: $cmd"
eval $cmd || error "x265: $cmd failed"
$MAKE -j$NJOBS x265-static || error "12bit: make x265-static failed"
cd -

# 10 bit
cd 10bit
cmd="$CMAKE $CMAKE_COMMON_ARGS $ARGS $HIGH_BIT_ARGS ../../source"
info "x265: $cmd"
eval $cmd || error "x265: $cmd failed"
$MAKE -j$NJOBS x265-static || error "10bit: make x265-static failed"
cd -

# 8 bit
cd 8bit
ln -svf ../10bit/libx265.a libx265_main10.a
ln -svf ../12bit/libx265.a libx265_main12.a

[ $BUILD_SHARED -eq 1 ] && ARGS+=" -DENABLE_SHARED=ON" || ARGS+=" -DENABLE_SHARED=OFF"
cmd="$CMAKE $CMAKE_COMMON_ARGS $ARGS -DEXTRA_LIB=\"x265_main10.a;x265_main12.a\" -DEXTRA_LINK_FLAGS=-L. -DLINKED_10BIT=ON -DLINKED_12BIT=ON ../../source"
info "x265: $cmd"
eval $cmd || error "x265: $cmd failed"

# x265 always install static lib
info "x265: make x265-static"
$MAKE -j$NJOBS x265-static || error "x265: make x265-static failed"
mv libx265.a libx265_main.a 
if [[ "$OSTYPE" == "darwin"* ]]; then
    libtool -static -o libx265.a libx265_main.a libx265_main10.a libx265_main12.a 2> /dev/null || error "libtool failed"
else
    $AR -M <<-'EOF'
CREATE libx265.a
ADDLIB libx265_main.a
ADDLIB libx265_main10.a
ADDLIB libx265_main12.a
SAVE
END
EOF
fi

info "x265: install..."
$MAKE install || error "make install failed"
cd -

if [ $BUILD_TEST -eq 1 ]; then
    $PREFIX/bin/x265 -V || error "test failed"
fi
