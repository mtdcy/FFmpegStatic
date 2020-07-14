cmake_minimum_required (VERSION 2.8)

project (FFmpegStatic)

# TODO: pull version from ffmpeg source
set (VERSION_MAJOR  1)
set (VERSION_MINOR  0)
set (VERSION_BUILD  1)

if (APPLE)
    set (TGT    "darwin19")
elseif (WIN32)
    set (TGT    "msys")
else()
    set (TGT    "linux")
endif()

set (FFMPEG_PREBUILTS   ${CMAKE_CURRENT_SOURCE_DIR}/${TGT}/prebuilts)
set (FFMPEG_SOURCES     ${CMAKE_CURRENT_SOURCE_DIR}/${TGT}/ffmpeg-4.1)
set (PKG_CONFIG_PATH_OLD    ENV{PKG_CONFIG_PATH})
set (ENV{PKG_CONFIG_PATH} "${FFMPEG_PREBUILTS}/lib/pkgconfig")  # for pkg-config

# project settings
if (APPLE)
    set (CMAKE_MACOSX_RPATH TRUE)
endif()

if (XCODE)
    set (CMAKE_XCODE_ATTRIBUTE_SIGN_IDENTITY "macOS Developer")
    #set (CMAKE_XCODE_ATTRIBUTE_MACOSX_DEPLOYMENT_TARGET 10.8)
endif()
set (CMAKE_C_VISIBILITY_PRESET hidden)

set (CMAKE_INCLUDE_CURRENT_DIR ON)

# TODO: pull from ffmpeg's config.h
#set (FFMPEG_LIBS libavutil libavcodec libavformat libavfilter libswresample libswscale libavdevice libpostproc)
set (FFMPEG_LIBS libavutil libavcodec libavformat)

# private headers
foreach (LIB ${FFMPEG_LIBS})
    file (GLOB _HEADERS RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "${CMAKE_CURRENT_SOURCE_DIR}/include/${LIB}/*.h")
    list (APPEND PRIVATE_HEADERS ${_HEADERS})
    set (HAS_${LIB} TRUE)
endforeach()

# public headers
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/FFmpeg.h.in ${CMAKE_CURRENT_SOURCE_DIR}/include/FFmpeg.h)
set (FFMPEG_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/include/FFmpeg.h)

# our target 
add_library(${PROJECT_NAME} SHARED stub.cpp ${FFMPEG_HEADERS} ${PRIVATE_HEADERS})
include_directories (${CMAKE_CURRENT_SOURCE_DIR}/include)

find_package (PkgConfig REQUIRED)
foreach (LIB ${FFMPEG_LIBS})
    pkg_check_modules (${LIB} REQUIRED NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH ${LIB})
    #target_link_libraries (${PROJECT_NAME} ${${LIB}_STATIC_LIBRARIES})
    list (APPEND EXTRA_LINK_FLAGS ${${LIB}_STATIC_LDFLAGS} ${${LIB}_STATIC_LDFLAGS_OTHER})
endforeach()

# control visibility of symbols
if (CMAKE_COMPILER_IS_GNUCC)
    # https://sourceware.org/binutils/docs/ld/VERSION.html
    list (APPEND EXTRA_LINK_FLAGS "-Wl,--version-script,${CMAKE_CURRENT_SOURCE_DIR}/FFmpeg.ver")
else()
    list (APPEND EXTRA_LINK_FLAGS "-Wl,-exported_symbols_list,${CMAKE_CURRENT_SOURCE_DIR}/FFmpeg.syms")
endif()
string (REPLACE ";" " " EXTRA_LINK_FLAGS "${EXTRA_LINK_FLAGS}")
message ("${EXTRA_LINK_FLAGS}")
set_target_properties(${PROJECT_NAME} PROPERTIES LINK_FLAGS "${EXTRA_LINK_FLAGS}")

##############################################################################
# install
if (XCODE)
    # libraries headers
    foreach (LIB ${FFMPEG_LIBS})
        file (GLOB _HEADERS "${CMAKE_CURRENT_SOURCE_DIR}/include/${LIB}/*.h")
        set_property(SOURCE ${_HEADERS} PROPERTY MACOSX_PACKAGE_LOCATION Headers/${LIB})
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

    #install (PROGRAMS ${FFMPEG_PREBUILTS}/bin/ffmpeg DESTINATION ${_DEST})
    #install (PROGRAMS ${FFMPEG_PREBUILTS}/bin/ffprobe DESTINATION ${_DEST})
    #install (PROGRAMS ${FFMPEG_PREBUILTS}/bin/ffplay DESTINATION ${_DEST})
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
    install (PROGRAMS ${FFMPEG_PREBUILTS}/bin/ffmpeg DESTINATION bin)
    install (PROGRAMS ${FFMPEG_PREBUILTS}/bin/ffprobe DESTINATION bin)
    #install (PROGRAMS ${FFMPEG_PREBUILTS}/bin/ffplay DESTINATION bin)
    install (TARGETS ${PROJECT_NAME} DESTINATION lib)

    # Headers
    install (FILES ${FFMPEG_HEADERS} DESTINATION include)
    foreach (LIB ${FFMPEG_LIBS})
        install(DIRECTORY include/${LIB} DESTINATION include)
    endforeach()

    # Resources 
    if (EXISTS ${FFMPEG_PREBUILTS}/lib/frei0r-1)
        install (DIRECTORY ${FFMPEG_PREBUILTS}/lib/frei0r-1 DESTINATION bin)
        install (PROGRAMS frei0r.sh DESTINATION bin RENAME frei0r)
    endif()

    file (GLOB _LICENSE "${FFMPEG_SOURCES}/COPYING*")
    install (FILES ${_LICENSE} DESTINATION share/${PROJECT_NAME})
    install (FILES ${FFMPEG_SOURCES}/VERSION DESTINATION share/${PROJECT_NAME})
    install (FILES ${FFMPEG_SOURCES}/RELEASE DESTINATION share/${PROJECT_NAME})
    install (FILES ${FFMPEG_SOURCES}/RELEASE_NOTES DESTINATION share/${PROJECT_NAME})
    install (FILES ${FFMPEG_SOURCES}/Changelog DESTINATION share/${PROJECT_NAME})

    if (WIN32)
    endif()
endif()

# restore PKG_CONFIG_PATH
set (ENV{PKG_CONFIG_PATH} ${PKG_CONFIG_PATH_OLD})
