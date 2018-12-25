# FFmpegStatic 

This project includes:

- bash script for creating static libraries of ffmpeg and its dependencies
- CMakeLists.txt and stub code for creating bundle for different os
- bash script for create IDE files for xcode


## TODO LIST

* libFFmpeg.so for Linux [DONE]
* FFmpeg.framework for macOS [DONE]
* FFmpeg.framework for iOS
* libFFmpeg.so for Android 


## Notes

- using stub loader instead of --whole-archive, @see stub.c.
- always build shared library even we only need the static one, so we can check library dependency on shared library using commands like 'otool -L path_to_shared_library'.
- we don't like GPL, it is not commercial friendly. so don't --enable-gpl if you don't like GPL either.
- 
