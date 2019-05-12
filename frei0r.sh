#!/bin/sh

cd `dirname $0` && SOURCE=`pwd` && cd -
FREI0R_PATH=$SOURCE/Resources/frei0r-1/ $SOURCE/main $@
