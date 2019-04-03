cmake_minimum_required (VERSION 2.8)

project (FFmpeg)

# macro for import local static library
macro (import_static_prebuilt library) 
    find_library(LIB_${library}
        NAMES lib${library}.a
        NAMES lib${library}.dll.a
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

if(WIN32)
    set (CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS TRUE)
else()
    set (CMAKE_C_VISIBILITY_PRESET hidden) # we don't need export symbols in FFmpeg.c
endif()

if (APPLE)
    set (CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
    set (CMAKE_XCODE_ATTRIBUTE_SIGN_IDENTITY "macOS Developer")
    #set (CMAKE_XCODE_ATTRIBUTE_MACOSX_DEPLOYMENT_TARGET 10.8)
endif()

set (CMAKE_INCLUDE_CURRENT_DIR ON)

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
    file (APPEND ${CMAKE_CURRENT_BINARY_DIR}/FFmpegConfiguration.h "#define FFMPEG_HAS_${LIB}\n")
    list (APPEND PRIVATE_HEADERS ${_HEADERS})
endforeach()
file (APPEND ${CMAKE_CURRENT_BINARY_DIR}/FFmpegConfiguration.h "#endif\n")
list (APPEND FFMPEG_HEADERS ${CMAKE_CURRENT_BINARY_DIR}/FFmpegConfiguration.h)

# our target 
add_library(${PROJECT_NAME} SHARED stub.c ${FFMPEG_HEADERS} ${PRIVATE_HEADERS})

# include and links
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/prebuilts/include)
foreach (LIB ${FFMPEG_DEP_LIBS} ${FFMPEG_LIBS})
    target_link_libraries(${PROJECT_NAME} ${LIB})
endforeach()

# control visibility of symbols
if (CMAKE_COMPILER_IS_GNUCC)
    set_target_properties(${PROJECT_NAME} PROPERTIES
        LINK_FLAGS "-Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/FFmpeg.ver"
        )
else()
    set_target_properties(${PROJECT_NAME} PROPERTIES
        LINK_FLAGS "-Wl,-exported_symbols_list,${CMAKE_CURRENT_SOURCE_DIR}/FFmpeg.syms"
        )
endif()

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
else()
# TODO
endif()

# install
if (XCODE)
    # libraries headers
    foreach (LIB ${FFMPEG_LIBS})
        file (GLOB _HEADERS "prebuilts/include/lib${LIB}/*.h")
        set_property(SOURCE ${_HEADERS} PROPERTY MACOSX_PACKAGE_LOCATION Headers/lib${LIB})
    endforeach()

    set_target_properties(${PROJECT_NAME} PROPERTIES
        FRAMEWORK TRUE
        FRAMEWORK_VERSION A
        PUBLIC_HEADER "${FFMPEG_HEADERS}"
        MACOSX_FRAMEWORK_IDENTIFIER com.mtdcy.FFmpeg
        MACOSX_FRAMEWORK_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist
        )

    install (TARGETS ${PROJECT_NAME} 
        FRAMEWORK       DESTINATION ${CMAKE_INSTALL_PREFIX}
        PUBLIC_HEADER   DESTINATION ${CMAKE_INSTALL_PREFIX}/Headers
        )
else()
    # libraries headers
    foreach (LIB ${FFMPEG_LIBS})
        install(DIRECTORY prebuilts/include/lib${LIB} DESTINATION include/FFmpeg FILES_MATCHING PATTERN "*.h")
    endforeach()

    set_target_properties(${PROJECT_NAME} PROPERTIES
        PUBLIC_HEADER "${FFMPEG_HEADERS}"
        )

    install (TARGETS ${PROJECT_NAME} 
        PUBLIC_HEADER   DESTINATION ${CMAKE_INSTALL_PREFIX}/include/FFmpeg
        RUNTIME         DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
        ARCHIVE         DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
        LIBRARY         DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
        )
endif()
