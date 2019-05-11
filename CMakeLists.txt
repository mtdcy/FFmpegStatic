cmake_minimum_required (VERSION 2.8)

project (FFmpeg)

if (NOT DEFINED FFMPEG_PREBUILTS)
    message(FATAL_ERROR " FFMPEG_PREBUILTS is not set")
endif()
if (NOT DEFINED FFMPEG_SOURCES)
    message(STATUS " FFMPEG_SOURCES is not set")
endif()

# macro for import local static library
macro (import_static_prebuilt library) 
    find_library(LIB_${library}
        NAMES lib${library}.a
        PATHS ${FFMPEG_PREBUILTS}/lib 
        NO_DEFAULT_PATH
        )
    if (${LIB_${library}} STREQUAL LIB_${library}-NOTFOUND) 
        message (FATAL_ERROR ": Library ${library} not found in ${FFMPEG_PREBUILTS}/lib")
    else()
        message (STATIC ": Library ${library} found at ${LIB_${library}}")
    endif()
    add_library(${library} STATIC IMPORTED GLOBAL)
    set_property(TARGET ${library} PROPERTY IMPORTED_LOCATION ${LIB_${library}})
endmacro(import_static_prebuilt)

# project settings
if (APPLE)
    set (CMAKE_MACOSX_RPATH TRUE)
endif()

set (CMAKE_C_VISIBILITY_PRESET hidden)

if (APPLE)
    set (CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
    set (CMAKE_XCODE_ATTRIBUTE_SIGN_IDENTITY "macOS Developer")
    #set (CMAKE_XCODE_ATTRIBUTE_MACOSX_DEPLOYMENT_TARGET 10.8)
endif()

set (CMAKE_INCLUDE_CURRENT_DIR ON)

set (FFMPEG_LIBS avutil avcodec avformat avfilter swresample swscale avdevice)
set (FFMPEG_DEP_LIBS 
    z bz2 lzma iconv xml2
    fdk-aac mp3lame ogg vorbis vorbisenc opus 
    webpmux webp theoraenc theoradec openh264 kvazaar vpx
    openjp2 
    soxr)

foreach (LIB ${FFMPEG_DEP_LIBS} ${FFMPEG_LIBS}) 
    message(STATUS ": import ${LIB}")
    import_static_prebuilt(${LIB})
endforeach()

# headers
set (FFMPEG_HEADERS FFmpeg.h)
file (WRITE ${CMAKE_CURRENT_BINARY_DIR}/FFmpegConfiguration.h "
// Created by Chen Fang.
// Copyright (c) 2018 Chen Fang. All rights reserved.
#ifndef __FFMPEG_CONFIGURATION_H__
#define __FFMPEG_CONFIGURATION_H__
")
foreach (LIB ${FFMPEG_LIBS})
    file (GLOB _HEADERS RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "${FFMPEG_PREBUILTS}/include/lib${LIB}/*.h")
    file (APPEND ${CMAKE_CURRENT_BINARY_DIR}/FFmpegConfiguration.h "#define FFMPEG_HAS_${LIB}\n")
    list (APPEND PRIVATE_HEADERS ${_HEADERS})
endforeach()
file (APPEND ${CMAKE_CURRENT_BINARY_DIR}/FFmpegConfiguration.h "#endif\n")
list (APPEND FFMPEG_HEADERS ${CMAKE_CURRENT_BINARY_DIR}/FFmpegConfiguration.h)

# our target 
add_library(${PROJECT_NAME} SHARED stub.cpp ${FFMPEG_HEADERS} ${PRIVATE_HEADERS})

# include and links
include_directories(${FFMPEG_PREBUILTS}/include)
if (CMAKE_COMPILER_IS_GNUCC)
    target_link_libraries(${PROJECT_NAME} -Wl,--whole-archive -Wl,--start-group ${FFMPEG_DEP_LIBS} ${FFMPEG_LIBS} -Wl,--end-group)
else()
    target_link_libraries(${PROJECT_NAME} ${FFMPEG_DEP_LIBS} ${FFMPEG_LIBS})
endif()

# control visibility of symbols
if (CMAKE_COMPILER_IS_GNUCC)
    # https://sourceware.org/binutils/docs/ld/VERSION.html
    set_target_properties(${PROJECT_NAME} PROPERTIES
        LINK_FLAGS "-Wl,--version-script,${CMAKE_CURRENT_SOURCE_DIR}/FFmpeg.ver"
        )
else()
    set_target_properties(${PROJECT_NAME} PROPERTIES
        LINK_FLAGS "-Wl,-exported_symbols_list,${CMAKE_CURRENT_SOURCE_DIR}/FFmpeg.syms"
        )
endif()

# link apple frameworks
if (APPLE)
    set (FFMPEG_DEP_FRAMEWORKS 
        Foundation CoreFoundation AVFoundation
        CoreMedia CoreVideo CoreGraphics CoreServices CoreImage 
        AudioToolbox VideoToolbox 
        OpenCL OpenGL
        AppKit Security)
    foreach (FRAMEWORK ${FFMPEG_DEP_FRAMEWORKS})
        target_link_libraries(${PROJECT_NAME} "-framework ${FRAMEWORK}")
    endforeach()
    target_link_libraries(${PROJECT_NAME} -lobjc)
elseif(WIN32)
    target_link_libraries(${PROJECT_NAME} -lbcrypt -lmsvcrt -lsecur32 -lws2_32 -lwinpthread)
else()
    # FIXME
endif()

##############################################################################
# rebuilt ffmpeg using our framework
if (DEFINED FFMPEG_SOURCES)
    add_executable(main 
        ${FFMPEG_SOURCES}/fftools/ffmpeg.c 
        ${FFMPEG_SOURCES}/fftools/cmdutils.c 
        ${FFMPEG_SOURCES}/fftools/ffmpeg_filter.c 
        ${FFMPEG_SOURCES}/fftools/ffmpeg_hw.c
        ${FFMPEG_SOURCES}/fftools/ffmpeg_opt.c 
        ${FFMPEG_SOURCES}/fftools/ffmpeg_videotoolbox.c 
        ${FFMPEG_SOURCES}/fftools/ffmpeg_cuvid.c
        )
    include_directories (${FFMPEG_SOURCES})
    include_directories (${FFMPEG_SOURCES}/fftools)
    target_link_libraries(main ${PROJECT_NAME})
endif()

##############################################################################
# install
if (XCODE)
    # libraries headers
    foreach (LIB ${FFMPEG_LIBS})
        file (GLOB _HEADERS "${FFMPEG_PREBUILTS}/include/lib${LIB}/*.h")
        set_property(SOURCE ${_HEADERS} PROPERTY MACOSX_PACKAGE_LOCATION Headers/lib${LIB})
    endforeach()

    set_target_properties(${PROJECT_NAME} PROPERTIES
        FRAMEWORK TRUE
        FRAMEWORK_VERSION A
        PUBLIC_HEADER   "${FFMPEG_HEADERS}"
        MACOSX_FRAMEWORK_IDENTIFIER com.mtdcy.FFmpeg
        MACOSX_FRAMEWORK_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist
        )

    install (TARGETS ${PROJECT_NAME} 
        FRAMEWORK       DESTINATION     .
        RESOURCE        DESTINATION     Resources
        PUBLIC_HEADER   DESTINATION     Headers
        )

    if (DEFINED FFMPEG_SOURCES)
        # ugly code
        install (TARGETS main DESTINATION ${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}.framework/Resources)
    endif()
else()
    # libraries headers
    foreach (LIB ${FFMPEG_LIBS})
        install(DIRECTORY ${FFMPEG_PREBUILTS}/include/lib${LIB} DESTINATION include/FFmpeg FILES_MATCHING PATTERN "*.h")
    endforeach()

    set_target_properties(${PROJECT_NAME} PROPERTIES
        PUBLIC_HEADER "${FFMPEG_HEADERS}"
        )

    install (TARGETS ${PROJECT_NAME} 
        PUBLIC_HEADER   DESTINATION     include/FFmpeg
        RUNTIME         DESTINATION     bin
        ARCHIVE         DESTINATION     lib
        LIBRARY         DESTINATION     lib
        )
endif()
