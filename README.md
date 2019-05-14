# FFmpegStatic 

This project includes:

- bash script for creating static libraries of ffmpeg and its dependencies
- CMakeLists.txt and stub code for creating bundle for different os
- bash script for create IDE files for xcode

## Features

* 

## TODO LIST

* libFFmpeg.so for Linux [DONE]
* FFmpeg.framework for macOS [DONE]
* FFmpeg.framework for iOS
* FFmpeg.dll for Windows 
* libFFmpeg.so for Android 
* control visibility of symbols in linked static libraries [DONE]

## Notes

- using stub loader instead of --whole-archive, @see stub.c.
- build shared library to check library dependency using commands like 'otool -L path_to_shared_library' or 'ldd path_to_shared_library' or 'objdump -p test.exe | grep DLL'.
- I don't like GPL, it is not commercial friendly. If you perfer GPL, build libraries using 'BUILD_GPL=1 ./build.sh'
- usally only one c library inside system, but multi c++ libraries. how to make sure all libraries using the same c++ library ?

## LICENSE

LGPL or GPL, See ffmpeg license.

## BUILD

### MSYS2+MinGW64

```bash
pacman -S mingw64/mingw-w64-x86_64-toolchain
pacman -S mingw64/mingw-w64-x86_64-cmake
pacman -S mingw64/mingw-w64-x86_64-nasm
pacman -S mingw64/mingw-w64-x86_64-yasm
pacman -S wget diffutils tar openssl make
#pacman -S mingw64/mingw-w64-x86_64-opencl-headers
```

**using MSYS/make by default, if package prefer mingw32-make, switch to it**

```bash
$ ldd ../msys/bin/libopenh264.dll
        ntdll.dll => /c/Windows/SYSTEM32/ntdll.dll (0x7ffab92c0000)
        KERNEL32.DLL => /c/Windows/System32/KERNEL32.DLL (0x7ffab91c0000)
        KERNELBASE.dll => /c/Windows/System32/KERNELBASE.dll (0x7ffab7080000)
        msvcrt.dll => /c/Windows/System32/msvcrt.dll (0x7ffab84c0000)
        libgcc_s_seh-1.dll => /mingw64/bin/libgcc_s_seh-1.dll (0x61440000)
        libstdc++-6.dll => /mingw64/bin/libstdc++-6.dll (0x6fc40000)
        USER32.dll => /c/Windows/System32/USER32.dll (0x7ffab8220000)
        win32u.dll => /c/Windows/System32/win32u.dll (0x7ffab7050000)
        GDI32.dll => /c/Windows/System32/GDI32.dll (0x7ffab8710000)
        libwinpthread-1.dll => /mingw64/bin/libwinpthread-1.dll (0x64940000)
        gdi32full.dll => /c/Windows/System32/gdi32full.dll (0x7ffab62a0000)
        msvcp_win.dll => /c/Windows/System32/msvcp_win.dll (0x7ffab6550000)
        ucrtbase.dll => /c/Windows/System32/ucrtbase.dll (0x7ffab6680000)
        IMM32.DLL => /c/Windows/System32/IMM32.DLL (0x7ffab8490000)

```





### macOS+Xcode


### Linux

