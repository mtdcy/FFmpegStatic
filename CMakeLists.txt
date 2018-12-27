cmake_minimum_required (VERSION 2.8)

project (FFmpeg)

# macro for import local static library
macro (import_static_prebuilt library) 
    find_library(LIB_${library}
        NAMES lib${library}.a
        PATHS ${CMAKE_CURRENT_SOURCE_DIR}/prebuilts/lib 
        NO_DEFAULT_PATH
        )
    if (${LIB_${library}} STREQUAL LIB_${library}-NOTFOUND) 
        message (ERROR ": Library ${library} not found")
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

if (${CMAKE_GENERATOR} STREQUAL "Xcode")
    set (CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
    set (CMAKE_XCODE_ATTRIBUTE_SIGN_IDENTITY "macOS Developer")
    #set (CMAKE_XCODE_ATTRIBUTE_MACOSX_DEPLOYMENT_TARGET 10.8)
endif()

set (CMAKE_INCLUDE_CURRENT_DIR ON)
set (CMAKE_C_VISIBILITY_PRESET hidden) # we don't need export symbols in FFmpeg.c

set (FFMPEG_LIBS avutil avcodec avformat avfilter swresample swscale avdevice)
set (FFMPEG_DEP_LIBS z bz2 lzma iconv)

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
    file (GLOB _HEADERS RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "prebuilts/include/lib${LIB}/*.h")
    list (APPEND FFMPEG_HEADERS ${_HEADERS})
    file (APPEND ${CMAKE_CURRENT_BINARY_DIR}/FFmpegConfiguration.h "#define FFMPEG_HAS_${LIB}\n")
endforeach()
file (APPEND ${CMAKE_CURRENT_BINARY_DIR}/FFmpegConfiguration.h "#endif\n")
list (APPEND FFMPEG_HEADERS ${CMAKE_CURRENT_BINARY_DIR}/FFmpegConfiguration.h)

# our target 
add_library(${PROJECT_NAME} SHARED stub.c ${FFMPEG_HEADERS})

# include and links
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/prebuilts/include)
foreach (LIB ${FFMPEG_DEP_LIBS} ${FFMPEG_LIBS})
    target_link_libraries(${PROJECT_NAME} ${LIB})
endforeach()

# control visibility of symbols
set_target_properties(${PROJECT_NAME} PROPERTIES
    LINK_FLAGS "-Wl,-exported_symbols_list,${CMAKE_CURRENT_SOURCE_DIR}/FFmpeg.syms"
    )

# link apple frameworks
if (APPLE)
    set (FFMPEG_DEP_FRAMEWORKS 
        Foundation CoreFoundation 
        CoreMedia CoreVideo CoreGraphics CoreServices CoreImage 
        AudioToolbox VideoToolbox 
        OpenCL OpenGL
        AppKit Security)
    foreach (FRAMEWORK ${FFMPEG_DEP_FRAMEWORKS})
        target_link_libraries(${PROJECT_NAME} "-framework ${FRAMEWORK}")
    endforeach()
endif()

# install
if (${CMAKE_GENERATOR} STREQUAL "Xcode")
    # public headers
    foreach (LIB ${FFMPEG_LIBS})
        file (GLOB _HEADERS "prebuilts/include/lib${LIB}/*.h")
        set_property(SOURCE ${_HEADERS} PROPERTY MACOSX_PACKAGE_LOCATION Headers/lib${LIB})
    endforeach()

    set_target_properties(${PROJECT_NAME} PROPERTIES
        FRAMEWORK TRUE
        FRAMEWORK_VERSION A
        PUBLIC_HEADER "FFmpeg.h;${CMAKE_CURRENT_BINARY_DIR}/FFmpegConfiguration.h"
        MACOSX_FRAMEWORK_IDENTIFIER com.mtdcy.FFmpeg
        MACOSX_FRAMEWORK_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist
        )
else()
    # public headers
    foreach (LIB ${FFMPEG_LIBS})
        install(DIRECTORY prebuilts/include/lib${LIB} DESTINATION include/FFmpeg FILES_MATCHING PATTERN "*.h")
    endforeach()

    install(FILES FFmpeg.h DESTINATION include/FFmpeg)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/FFmpegConfiguration.h DESTINATION include/FFmpeg)
endif()

install (TARGETS ${PROJECT_NAME}
    FRAMEWORK DESTINATION Library/Frameworks
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    )

