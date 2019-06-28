cmake_minimum_required (VERSION 2.8)

project (FFmpegStatic)

# TODO: pull version from ffmpeg source
set (VERSION_MAJOR  0)
set (VERSION_MINOR  2)
set (VERSION_BUILD  1)

if (NOT DEFINED FFMPEG_PREBUILTS)
    message(FATAL_ERROR " FFMPEG_PREBUILTS is not set")
endif()
if (NOT DEFINED FFMPEG_SOURCES)
    message(FATAL_ERROR " FFMPEG_SOURCES is not set")
endif()

# project settings
if (APPLE)
    set (CMAKE_MACOSX_RPATH TRUE)
endif()

set (CMAKE_INSTALL_RPATH    "./")   # for ffmpeg
if (XCODE)
    set (CMAKE_XCODE_ATTRIBUTE_SIGN_IDENTITY "macOS Developer")
    #set (CMAKE_XCODE_ATTRIBUTE_MACOSX_DEPLOYMENT_TARGET 10.8)
endif()
set (CMAKE_C_VISIBILITY_PRESET hidden)

set (CMAKE_INCLUDE_CURRENT_DIR ON)

# TODO: pull from ffmpeg's config.h
set (FFMPEG_LIBS libavutil libavcodec libavformat libavfilter libswresample libswscale libavdevice libpostproc)

# headers
foreach (LIB ${FFMPEG_LIBS})
    set (HAS_${LIB}     TRUE)
endforeach()
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/FFmpeg.h.in FFmpeg.h)
set (FFMPEG_HEADERS ${CMAKE_CURRENT_BINARY_DIR}/FFmpeg.h)

# our target 
add_library(${PROJECT_NAME} SHARED stub.cpp ${FFMPEG_HEADERS} ${PRIVATE_HEADERS})
find_package (PkgConfig REQUIRED)
foreach (LIB ${FFMPEG_LIBS})
    pkg_check_modules (${LIB} REQUIRED ${LIB})
    message (STATUS "${LIB} : ${${LIB}_LIBRARIES}")
    message (STATUS "${LIB} : ${${LIB}_INCLUDE_DIRS}")
    target_link_libraries(${PROJECT_NAME} ${${LIB}_LIBRARIES})
    include_directories (${${LIB}_INCLUDE_DIRS})
endforeach()

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
    # FIXME: using pkg-config
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
endif()

##############################################################################
# rebuilt ffmpeg using our framework
set (ffmpeg_sources
    ${FFMPEG_SOURCES}/fftools/ffmpeg.c 
    ${FFMPEG_SOURCES}/fftools/cmdutils.c 
    ${FFMPEG_SOURCES}/fftools/ffmpeg_filter.c 
    ${FFMPEG_SOURCES}/fftools/ffmpeg_hw.c
    ${FFMPEG_SOURCES}/fftools/ffmpeg_opt.c 
    ${FFMPEG_SOURCES}/fftools/ffmpeg_cuvid.c
    )
if (APPLE)
    list (APPEND ffmpeg_sources ${FFMPEG_SOURCES}/fftools/ffmpeg_videotoolbox.c)
endif()
add_executable(ffmpeg ${ffmpeg_sources})
include_directories (${FFMPEG_SOURCES})     # config.h
include_directories (${FFMPEG_SOURCES}/fftools)
target_link_libraries(ffmpeg ${PROJECT_NAME})

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
        VERSION         "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_BUILD}"
        SOVERSION       "${VERSION_MAJOR}.${VERSION_MINOR}"
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
    if (EXISTS ${FFMPEG_PREBUILTS}/lib/frei0r-1)
        file (GLOB frei0r "${FFMPEG_PREBUILTS}/lib/frei0r-1/*")
        install(DIRECTORY DESTINATION ${_DEST}/Resources/frei0r-1)
        foreach (so ${frei0r})
            get_filename_component(_so ${so} NAME_WE)
            install(FILES ${so} DESTINATION ${_DEST}/Resources/frei0r-1 RENAME ${_so}.dylib)
        endforeach()
        install (PROGRAMS frei0r.sh DESTINATION ${_DEST} RENAME frei0r)
    endif()

    install (TARGETS ffmpeg DESTINATION ${_DEST})
    file (GLOB _LICENSE "${FFMPEG_SOURCES}/COPYING*")
    install (FILES ${_LICENSE} DESTINATION ${_DEST}/Resources)
    install (FILES ${FFMPEG_SOURCES}/VERSION DESTINATION ${_DEST}/Resources)
    install (FILES ${FFMPEG_SOURCES}/RELEASE DESTINATION ${_DEST}/Resources)
    install (FILES ${FFMPEG_SOURCES}/RELEASE_NOTES DESTINATION ${_DEST}/Resources)
    install (FILES ${FFMPEG_SOURCES}/Changelog DESTINATION ${_DEST}/Resources)
else()
    set_target_properties(${PROJECT_NAME} PROPERTIES
        SOVERSION       "${VERSION_MAJOR}.${VERSION_MINOR}"
        VERSION         "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_BUILD}"
    )

    # Install all things to ${CMAKE_INSTALL_PREFIX}
    install (TARGETS ffmpeg DESTINATION ${CMAKE_INSTALL_PREFIX})
    install (TARGETS ${PROJECT_NAME} DESTINATION ${CMAKE_INSTALL_PREFIX})

    # Headers
    install (FILES ${FFMPEG_HEADERS} DESTINATION ${CMAKE_INSTALL_PREFIX})
    foreach (LIB ${FFMPEG_LIBS})
        install(DIRECTORY ${FFMPEG_PREBUILTS}/include/${LIB} DESTINATION ${CMAKE_INSTALL_PREFIX})
    endforeach()

    # Resources 
    if (EXISTS ${FFMPEG_PREBUILTS}/lib/frei0r-1)
        install (DIRECTORY ${FFMPEG_PREBUILTS}/lib/frei0r-1 DESTINATION ${CMAKE_INSTALL_PREFIX}/Resources)
        install (PROGRAMS frei0r.sh DESTINATION ${CMAKE_INSTALL_PREFIX} RENAME frei0r)
    endif()

    file (GLOB _LICENSE "${FFMPEG_SOURCES}/COPYING*")
    install (FILES ${_LICENSE} DESTINATION ${CMAKE_INSTALL_PREFIX}/Resources)
    install (FILES ${FFMPEG_SOURCES}/VERSION DESTINATION ${CMAKE_INSTALL_PREFIX}/Resources)
    install (FILES ${FFMPEG_SOURCES}/RELEASE DESTINATION ${CMAKE_INSTALL_PREFIX}/Resources)
    install (FILES ${FFMPEG_SOURCES}/RELEASE_NOTES DESTINATION ${CMAKE_INSTALL_PREFIX}/Resources)
    install (FILES ${FFMPEG_SOURCES}/Changelog DESTINATION ${CMAKE_INSTALL_PREFIX}/Resources)

    if (WIN32)
    endif()
endif()
