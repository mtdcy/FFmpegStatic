#!/bin/bash
#
# GPL

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://downloads.xvid.com/downloads/xvidcore-1.3.5.tar.bz2
sha256=7c20f279f9d8e89042e85465d2bcb1b3130ceb1ecec33d5448c4589d78f010b4

function install() {
    ARGS="--prefix=$PREFIX"

    cd build/generic
    info "xvidcore: ./configure $ARGS"
    ./configure $ARGS || return 1
    $MAKE -j$NJOBS all || return 1
    $MAKE install || return 1

    # always remove shared lib
    if [[ "$OSTYPE" == "msys" ]]; then
        rm -rvf $PREFIX/lib/xvidcore.dll.a
        rm -rvf $PREFIX/bin/xvidcore.dll
        mv $PREFIX/lib/xvidcore.a $PREFIX/lib/libxvidcore.a
    elif [[ $"OSTYPE" == "darwin"* ]]; then
        rm -rvf $PREFIX/lib/libxvidcore.*.dylib 
    else
        rm -rvf $PREFIX/lib/libxvidcore.*.so
    fi

    if [ $BUILD_TEST -eq 1 ]; then 
        cat > test.cpp <<-'EOF'
#include <xvid.h>
#define NULL 0
int main() {
    xvid_gbl_init_t xvid_gbl_init;
    xvid_global(NULL, XVID_GBL_INIT, &xvid_gbl_init, NULL);
    return 0;
}
EOF
       
        $CXX $CXXFLAGS $LDFLAGS test.cpp -lxvidcore -o test || return
        ./test || return 
    fi

    sed -i '/xvidcore:/d' $PREFIX/LIBRARIES.txt || return
    echo "xvidcore: 1.3.5" >> $PREFIX/LIBRARIES.txt || return
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd xvidcore*/ &&
install || { error "build xvidcore failed"; exit 1; }

