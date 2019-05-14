# FFmpegStatic 

Build static [FFmpeg](https://ffmpeg.org/) bundle for MacOS(Xcode) | Windows | Linux. This Project includes:

- [bash script](build.sh) for creating static libraries of FFmpeg and its dependencies
- [CMakeLists.txt](CMakeLists.txt) and [stub code](stub.cpp) for creating bundle for different os

## External Libraries

* libiconv: 1.15
* zlib: 1.2.11
* bzip2: 1.0.6
* lzma: 5.2.4
* soxr: 0.1.3
* lame: 3.100
* libogg: 1.3.3
* libvorbis: 1.3.6
* opencore-amr: 0.1.5
* opus: 1.3.1
* fdk-aac: 2.0.0
* libpng: 1.6.37
* giflib: 5.1.4
* libjpeg-turbo: 2.0.2
* libtiff: 4.0.10
* libwebp: 1.0.2
* openjpeg: 2.3.1
* libtheora: 1.1.1
* libvpx: 1.8.0
* openh264: 1.8.0
* kvazaar: 1.2.0
* x264: HEAD
* x265: 3.0
* xvidcore: 1.3.5
* frei0r: 1.6.1
* libxml2: 2.9.9

## Notes

- using stub loader instead of --whole-archive, @see stub.cpp.
- build shared library to check library dependency using commands like 'otool -L path_to_shared_library' or 'ldd path_to_shared_library' or 'objdump -p test.exe | grep DLL'.
- I don't like GPL, it is not commercial friendly. If you perfer GPL, build libraries using 'BUILD_GPL=1 ./build.sh'
- usally only one c library inside system, but multi c++ libraries. how to make sure all libraries using the same c++ library ?

## Build From Source

### Configure Your Host

#### MSYS2+MinGW64

```bash
pacman -S mingw64/mingw-w64-x86_64-toolchain
pacman -S mingw64/mingw-w64-x86_64-cmake
pacman -S mingw64/mingw-w64-x86_64-nasm
pacman -S mingw64/mingw-w64-x86_64-yasm
pacman -S wget diffutils tar openssl make
```

#### macOS+Xcode

configure host with brew or what ever you want. 

#### Linux

configure host with its own package manager system.

### Build Libraries

```bash
# step 1:
# build shared libraries to make sure it does NOT link to host libraries
BUILD_GPL=1 BUILD_NONFREE=1 BUILD_DEPS=1 BUILD_SHARED=1 ./build.sh

# step 2:
# build only static 
BUILD_GPL=1 BUILD_NONFREE=1 BUILD_DEPS=1 BUILD_SHARED=0 ./build.sh

# step 3:
# build bundle
cmake -DFFMPEG_PREBUILTS=<...> -DFFMPEG_SOURCES=<...> <path_to_project>
make
```

## LICENSE

* This Project is licensed under BSD 2-Clause License
* The target bundle is either LGPL or GPL, see FFmpeg license notes.

