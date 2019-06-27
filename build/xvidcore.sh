#!/bin/bash
#
# GPL

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

license="GPL"
version=1.3.5
url=https://downloads.xvid.com/downloads/xvidcore-$version.tar.bz2
sha256=7c20f279f9d8e89042e85465d2bcb1b3130ceb1ecec33d5448c4589d78f010b4

prepare_pkg_source $url $sha256 $SOURCE/packages/`basename $url` && cd xvidcore*/

ARGS="--prefix=$PREFIX"

cd build/generic
info "xvidcore: ./configure $ARGS"
./configure $ARGS || error "configure failed"
$MAKE -j$NJOBS all || error "make all failed"

rm -rf $PREFIX/lib/libxvidcore.*    # fix error: symbolic link exists
$MAKE install || error "make install failed"

if [ $BUILD_SHARED -eq 0 ]; then
    # force link to static lib by removing shared lib 
    if [[ "$OSTYPE" == "msys" ]]; then
        rm -rvf $PREFIX/lib/xvidcore.dll.a
        rm -rvf $PREFIX/bin/xvidcore.dll
        mv $PREFIX/lib/xvidcore.a $PREFIX/lib/libxvidcore.a
    elif [[ $"OSTYPE" == "darwin"* ]]; then
        rm -rvf $PREFIX/lib/libxvidcore.*.dylib 
    else
        rm -rvf $PREFIX/lib/libxvidcore.so*
    fi
fi
