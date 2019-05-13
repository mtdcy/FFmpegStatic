#!/bin/bash
#
# 

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://github.com/uclouvain/openjpeg/archive/v2.3.1.tar.gz
sha256=63f5a4713ecafc86de51bfad89cc07bb788e9bba24ebbf0c4ca637621aadb6a9

function install() {
    ARGS="-DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=Release -DBUILD_STATIC_LIBS=ON"
    ARGS+=" -DCMAKE_MAKE_PROGRAM=$MAKE" # CMAKE_MAKE_PROGRAM can NOT poplute by $MAKE
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" -DBUILD_SHARED_LIBS=ON"
    else
        ARGS+=" -DBUILD_SHARED_LIBS=OFF"
        # no applications
        ARGS+=" -DBUILD_CODEC=OFF"
    fi

    rm -rf tmp
    mkdir -p tmp && cd tmp

    info "openjpeg: cmake $ARGS .."
    if [[ "$OSTYPE" == "msys" ]]; then
        cmake -G"MSYS Makefiles" $ARGS .. || return
    else
        cmake $ARGS .. || return 1
    fi
    $MAKE -j$NJOBS install || return 1

    if [ $BUILD_TEST -eq 1 ]; then
        cat > test.c <<-'EOF'
#include <openjpeg-2.3/openjpeg.h>
int main () {
  opj_image_cmptparm_t cmptparm;
  const OPJ_COLOR_SPACE color_space = OPJ_CLRSPC_GRAY;
  opj_image_t *image;
  image = opj_image_create(1, &cmptparm, color_space);
  opj_image_destroy(image);
  return 0;
}
EOF
        $CC $CFLAGS $LDFLAGS test.c -lopenjp2 -o out || return
        ./out || return
    fi
    cd -

    sed -i '/openjpeg:/d' $PREFIX/LIBRARIES.txt || return
    echo "openjpeg: 2.3.1" >> $PREFIX/LIBRARIES.txt || return
}

download $url $sha256 openjpeg-`basename $url` &&
extract openjpeg-`basename $url` && 
cd openjpeg-*/ &&
install || { error "build openjpeg failed"; exit 1; }



