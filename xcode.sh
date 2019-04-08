#!/bin/bash

if [ ! -d xcode ]; then
    mkdir xcode 
fi

cd xcode

cmake -G Xcode -DCMAKE_INSTALL_PREFIX=~/Library/Frameworks ..

# better to build using xcode
#xcodebuild -alltargets -config Release clean install

cd -
