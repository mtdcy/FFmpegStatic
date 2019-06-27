#!/bin/sh

cd `dirname $0` && SOURCE=`pwd` && cd -
LD_LIBRARY_PATH=$SOURCE FREI0R_PATH=$SOURCE/Resources/frei0r-1/ $SOURCE/ffmpeg $@
