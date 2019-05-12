#!/bin/bash
# usage: zlib.sh <install_prefix>

SOURCE=`dirname $0`
source $SOURCE/cbox.sh

url=https://ffmpeg.org/releases/ffmpeg-4.1.tar.bz2 
sha256=b684fb43244a5c4caae652af9022ed5d85ce15210835bce054a33fb26033a1a5

# common codecs
DEMUXERS="aac,ac3,amr,ape,apng,aptx,asf,avi,eac3,flac,flv,gif,gsm,hls,m4v,matroska,mjpeg,mov,mp3,mpegps,mpegts,ogg,vc1,wav"
MUXERS="mov,mp3,mp4,flac,matroska,matroska_audio,ogg,wav"
A_DECODERS="aac,aac_fixed,aac_latm,ac3,ac3_fixed,alac,amrnb,amrwb,ape,aptx,aptx_hd,cook,dca,eac3,flac,g729,gsm,gsm_ms,mp1,mp1float,mp2,mp2float,mp3,mp3float,mp3adu,mp3adufloat,mp3on4,mp3on4float,als,opus,sbc,vorbis,wavpack,wmalossless,wmapro,wmav1,wmav2,wmavoice"
V_DECODERS="cavs,apng,flv,h261,h263,h263i,h263p,h264,hevc,jpeg2000,jpegls,mjpeg,mjpegb,mpeg1video,mpeg2video,mpegvideo,mpeg4,msmpeg4v1,msmpeg4v2,msmpeg4,png,rv10,rv20,rv30,rv40,vc1,vc1image,vp8,vp9,wmv1,wmv2,wmv3,wmv3image"
S_DECODERS="ssa,ass,dvbsub,dvdsub,mov_text,realtext,stl,srt"
A_ENCODERS=""
V_ENCODERS=""
S_ENCODERS=""

function install() {
    export FFMPEG_SOURCES=`pwd`
    # FFmpeg - GPL or LGPL
    ARGS="--prefix=$PREFIX --enable-static --enable-rpath --enable-pthreads --enable-hardcoded-tables"
    ARGS+=" --extra-ldflags=-L$PREFIX/lib --extra-cflags=-I$PREFIX/include"
    ARGS+=" --enable-nonfree"
    #ARGS+=" --pkg-config-flags=--static"
    if [ $BUILD_SHARED -eq 1 ]; then
        ARGS+=" --enable-shared"
    else
        ARGS+=" --disable-shared"
        # ffmpeg prefer shared libs, so need workarounds 
        sed -i 's/vorbis_info_init/& -logg/g' configure || return
        sed -i 's/vorbis_encode_init/& -lvorbis -logg/g' configure || return
        sed -i 's/xmlCheckVersion/& -lz -llzma -liconv/g' configure || return
        ARGS+=" --extra-ldflags=-liconv"
        ARGS+=" --extra-ldflags=-lc++"
    fi

    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '/frei0r_pathlist\[\] =/a \\t\t"Resources/frei0r-1/",' libavfilter/vf_frei0r.c || return
    fi

    if [ $BUILD_HUGE -eq 1 ]; then 
        ARGS+=" --enable-decoders --enable-encoders --enable-demuxers --enable-muxers"
    else
        ARGS+=" --disable-decoders --disable-encoders --disable-demuxers --disable-muxers"
        ARGS+=" --enable-demuxer=$DEMUXERS"
        ARGS+=" --enable-decoder=$A_DECODERS,$V_DECODERS,$S_DECODERS"
        [ $BUILD_ENCODER -eq 1 ] && ARGS+=" --enable-encoder=$A_ENCODERS,$V_ENCODERS,$S_ENCODERS"
        [ $BUILD_MUXER -eq 1 ] && ARGS+=" --enable-muxer=$MUXER"
    fi

    # external libraries
    ARGS+=" --disable-autodetect"   # manual control external libraries
    #ARGS+=" --enable-openssl"       # FIXME: always using system openssl
    ARGS+=" --enable-zlib"
    ARGS+=" --enable-bzlib"
    ARGS+=" --enable-lzma"
    ARGS+=" --enable-iconv"
    ARGS+=" --enable-libxml2"       # xml2 parser for dash demuxing
    ARGS+=" --enable-libsoxr"       # audio resampling
    ARGS+=" --enable-libmp3lame"    # mp3 encoding
    ARGS+=" --enable-libfdk-aac"    # aac encoding
    ARGS+=" --enable-libvorbis"     # vorbis encoding & decoding
    ARGS+=" --enable-libopus"       # opus encoding & decoding
    ARGS+=" --enable-libvpx"        # vp8 & vp9 encoding & decoding
    ARGS+=" --enable-libtheora"     # theora encoding 
    ARGS+=" --enable-libopenjpeg"   # jpeg 2000 encoding & decoding
    ARGS+=" --enable-libwebp"       # webp encoding
    #ARGS+=" --enable-libass"       # FIXME
    if [ $BUILD_GPL -eq 1 ]; then
        ARGS+=" --enable-gpl --enable-version3"
        ARGS+=" --enable-libopencore-amrnb"
        ARGS+=" --enable-libopencore-amrwb"
        ARGS+=" --enable-libx264"   # h264 encoding
        ARGS+=" --enable-libx265"   # hevc encoding
        ARGS+=" --enable-frei0r"    # frei0r 
    else
        ARGS+=" --enable-libopenh264"   # h264 encoding
        ARGS+=" --enable-libkvazaar"    # hevc encoding
    fi
    # platform hw accel
    # https://trac.ffmpeg.org/wiki/HWAccelIntro
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS frameworks for image&audio&video
        ARGS+=" --enable-avfoundation"
        ARGS+=" --enable-coreimage"
        ARGS+=" --enable-audiotoolbox"
        ARGS+=" --enable-videotoolbox"
        ARGS+=" --enable-opencl"
        ARGS+=" --enable-opengl"
    fi
    # for test
    ARGS+=" --samples=fate-suite/"
    info "ARGS: $ARGS"

    ./configure $ARGS || return 1
    make -j$NJOBS || return 1
    make install || return 1
    # build tools but no install
    make alltools || return 1
}

download $url $sha256 `basename $url` &&
extract `basename $url` && 
cd ffmpeg-4.1 &&
install || { error "build ffmpeg failed"; exit 1; }

