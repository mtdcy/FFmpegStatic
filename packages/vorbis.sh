#!/bin/bash
#
# BSD 3-Clause

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

license="BSD"
version=1.3.6
url=https://downloads.xiph.org/releases/vorbis/libvorbis-$version.tar.xz
sha256=af00bb5a784e7c9e69f56823de4637c350643deedaf333d0fa86ecdba6fcb415

function install() {
    ARGS="--prefix=$PREFIX --disable-debug --enable-static"
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" --enable-shared"
    else
        ARGS+=" --disable-shared"
    fi

    info "libvorbis: ./configure $ARGS"
    ./configure $ARGS || return 1
    $MAKE -j$NJOBS install || return 1

    if [ $BUILD_TEST -eq 1 ]; then 
        $MAKE check || return
        cat > a.c <<-'EOF'
#include <vorbis/vorbisfile.h>
#include <vorbis/codec.h>
#include <vorbis/vorbisenc.h>
int main(void) {
    ov_clear(NULL);
    vorbis_info vi; 
    vorbis_info_init(&vi);
    vorbis_encode_setup_init(&vi);
    return 0;
}
EOF
        $CC $CFLAGS $LDFLAGS a.c -lvorbisfile -lvorbis -lvorbisenc -logg -o a || return
        ./a || return
    fi

    sed -i '/libvorbis:/d' $PREFIX/LIBRARIES.txt || return
    echo "libvorbis: $version $license" >> $PREFIX/LIBRARIES.txt || return
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd libvorbis-*/ &&
install || { error "build libvorbis failed"; exit 1; }

