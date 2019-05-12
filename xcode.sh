#!/bin/bash

SOURCE=`pwd`/`dirname $0`
PREBUILTS=$SOURCE/build/$OSTYPE 
FFMPEG=`cd $SOURCE/build/ffmpeg-* && pwd && cd -`

ARGS="-G Xcode"
ARGS+=" -DCMAKE_IGNORE_PATH=\"/usr/local/lib;/usr/local/include\""
ARGS+=" -DCMAKE_INSTALL_PREFIX=~/Library/Frameworks"
ARGS+=" -DFFMPEG_PREBUILTS=$PREBUILTS"
ARGS+=" -DFFMPEG_SOURCES=$FFMPEG"

echo "cmake $ARGS"
rm -rf xcode && mkdir -p xcode && cd xcode 
rm -rf ~/Library/Frameworks/FFmpeg.framework
cmake $ARGS .. && xcodebuild -alltargets -config Release 
cd -
