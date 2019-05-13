#!/bin/bash
#
# BSD

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://github.com/cisco/openh264/archive/v1.8.0.tar.gz
sha256=08670017fd0bb36594f14197f60bebea27b895511251c7c64df6cd33fc667d34

function install() {
    # remove default value, using env instead
    info "openh264: $MAKE ..."
    sed -i '/^PREFIX=*/d' Makefile 

    if [[ "$OSTYPE" == "msys" ]]; then
        sed -i '/^CC =/d' build/platform-mingw_nt.mk
        sed -i '/^CXX =/d' build/platform-mingw_nt.mk
        sed -i '/^AR =/d' build/platform-mingw_nt.mk
    fi

    if [ $BUILD_SHARED -eq 1 ]; then
        PREFIX=$PREFIX $MAKE -j$NJOBS install-shared || return 1
    else
        PREFIX=$PREFIX $MAKE -j$NJOBS install-static || return 1
    fi

    if [ $BUILD_TEST -eq 1 ]; then
        cat > test.c <<-'EOF'
#include <wels/codec_api.h>
int main() {
    ISVCDecoder *dec;
    WelsCreateDecoder (&dec);
    WelsDestroyDecoder (dec);
    return 0;
}
EOF
        if [[ "$OSTYPE" == "msys" ]]; then
            $CC $CFLAGS $LDFLAGS test.c -lopenh264 -lstdc++ || return
            ./a.exe || return
        else
            $CC $CFLAGS $LDFLAGS test.c -lopenh264 -lc++ || return
            ./a.out || return
        fi
    fi

    sed -i '/openh264:/d' $PREFIX/LIBRARIES.txt || return
    echo "openh264: 1.8.0" >> $PREFIX/LIBRARIES.txt || return
}

download $url $sha256 openh264-`basename $url` &&
extract openh264-`basename $url` && 
cd openh264-*/ &&
install || { error "build openh264 failed"; exit 1; }


