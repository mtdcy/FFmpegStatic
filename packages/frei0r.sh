#!/bin/bash
#
# GPL

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://files.dyne.org/frei0r/releases/frei0r-plugins-1.6.1.tar.gz
sha256=e0c24630961195d9bd65aa8d43732469e8248e8918faa942cfb881769d11515e

function install() {
    ARGS="--prefix=$PREFIX --disable-debug --enable-shared"
    ./configure $ARGS || return 1
    make -j$NJOBS || return 1
    make install || return 1
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd frei0r* &&
install || { error "build frei0r failed"; exit 1; }

