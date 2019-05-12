cmake_minimum_required (VERSION 2.8)

project (FFmpeg)

set (VERSION_MAJOR  0)
set (VERSION_MINOR  1)
set (VERSION_BUILD  1)

if (NOT DEFINED FFMPEG_PREBUILTS)
    message(FATAL_ERROR " FFMPEG_PREBUILTS is not set")
endif()
if (NOT DEFINED FFMPEG_SOURCES)
    message(FATAL_ERROR " FFMPEG_SOURCES is not set")
endif()
option(WITH_EASY    "FFmpeg easy use interface"     ON)

# macro for import local static library
macro (import_static_prebuilt library) 
    set (_LOC ${FFMPEG_PREBUILTS}/lib/lib${library}.a)
    if (EXISTS ${_LOC})
        message (STATUS ": Library ${library} found @ ${_LOC}")
        add_library(${library} STATIC IMPORTED GLOBAL)
        set_property(TARGET ${library} PROPERTY IMPORTED_LOCATION ${_LOC})
    else()
        message (STATUS ": Library ${library} not found")
    endif()
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

set (FFMPEG_LIBS avutil avcodec avformat avfilter swresample swscale avdevice postproc)
set (FFMPEG_DEP_LIBS 
    z bz2 lzma iconv xml2
    fdk-aac mp3lame ogg vorbis vorbisenc opus opencore-amrnb opencore-amrwb
    webpmux webp theoraenc theoradec openh264 kvazaar vpx x264 x265
    openjp2 
    soxr)

foreach (LIB ${FFMPEG_DEP_LIBS} ${FFMPEG_LIBS}) 
    message(STATUS ": import ${LIB}")
    import_static_prebuilt(${LIB})
    if (TARGET ${LIB})
        list(APPEND IMPORTED_LIBS ${LIB})
    endif()
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
    target_link_libraries(${PROJECT_NAME} -Wl,--whole-archive -Wl,--start-group ${IMPORTED_LIBS} -Wl,--end-group)
else()
    target_link_libraries(${PROJECT_NAME} ${IMPORTED_LIBS})
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

if (WITH_EASY) 
    add_executable(easy easy.cpp)
    find_library (ABE NAMES ABE PATHS ${CMAKE_INSTALL_PREFIX} NO_DEFAULT_PATH)
    message("ABE: ${ABE}")
    target_link_libraries(easy ${ABE})
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
        VERSION         "${VERSION_MAJOR}.${VERSION_MINOR}"
        SOVERSION       "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_BUILD}"
        PUBLIC_HEADER   "${FFMPEG_HEADERS}"
        MACOSX_FRAMEWORK_IDENTIFIER com.mtdcy.FFmpeg
        MACOSX_FRAMEWORK_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist
        )

    install (TARGETS ${PROJECT_NAME} 
        FRAMEWORK       DESTINATION     ${CMAKE_INSTALL_PREFIX}
        RESOURCE        DESTINATION     Resources
        PUBLIC_HEADER   DESTINATION     Headers
        )

    # ugly install code
    set (_DEST ${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}.framework)
    install (FILES ${FFMPEG_PREBUILTS}/LIBRARIES.txt DESTINATION ${_DEST}/Resources)
    if (EXISTS ${FFMPEG_PREBUILTS}/lib/frei0r-1)
        file (GLOB frei0r "${FFMPEG_PREBUILTS}/lib/frei0r-1/*")
        install(DIRECTORY DESTINATION ${_DEST}/Resources/frei0r-1)
        foreach (so ${frei0r})
            get_filename_component(_so ${so} NAME_WE)
            install(FILES ${so} DESTINATION ${_DEST}/Resources/frei0r-1 RENAME ${_so}.dylib)
        endforeach()
    endif()

    install (TARGETS main DESTINATION ${_DEST})
    install (PROGRAMS frei0r.sh DESTINATION ${_DEST} RENAME frei0r)
    file (GLOB _LICENSE "${FFMPEG_SOURCES}/COPYING*")
    install (FILES ${_LICENSE} DESTINATION ${_DEST}/Resources)
    install (FILES ${FFMPEG_SOURCES}/VERSION DESTINATION ${_DEST}/Resources)
    install (FILES ${FFMPEG_SOURCES}/RELEASE DESTINATION ${_DEST}/Resources)
    install (FILES ${FFMPEG_SOURCES}/RELEASE_NOTES DESTINATION ${_DEST}/Resources)
    install (FILES ${FFMPEG_SOURCES}/Changelog DESTINATION ${_DEST}/Resources)
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
