# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/sbml/files/libsbml/5.18.0/stable/libSBML-5.18.0-core-plus-packages-src.tar.gz/download"
    FILENAME "libSBML-5.18.0.zip"
    SHA512 49dedaa2fcd2077e7389a8f940adf931d80aa7a8f9d57330328372d2ac8ebcaeb03a20524df2fe0f1c6933587904613754585076c46e6cb5d6f7a001f427185b
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE} 
    # (Optional) A friendly name to use instead of the filename of the archive (e.g.: a version number or tag).
    # REF 1.0.0
    # (Optional) Read the docs for how to generate patches at: 
    # https://github.com/Microsoft/vcpkg/blob/master/docs/examples/patching.md
    # PATCHES
    #   001_port_fixes.patch
    #   002_more_port_fixes.patch
)

SET(ENABLE_EXPAT ON)
SET(ENABLE_LIBXML OFF)
SET(ENABLE_COMP ON)
SET(ENABLE_FBC ON)
SET(ENABLE_GROUPS ON)
SET(ENABLE_LAYOUT ON)
SET(ENABLE_MULTI OFF)
SET(ENABLE_QUAL OFF)
SET(ENABLE_RENDER ON)
SET(WITH_BZIP2 OFF)
SET(WITH_ZLIB OFF)
SET(STATIC_RUNTIME OFF)
SET(WITH_CHECK OFF)

if (VCPKG_CRT_LINKAGE AND ${VCPKG_CRT_LINKAGE} MATCHES "static")
SET(STATIC_RUNTIME ON)
endif()

if("expat" IN_LIST FEATURES)
SET(ENABLE_EXPAT ON)
SET(ENABLE_LIBXML OFF)
endif()

if("libxml" IN_LIST FEATURES)
SET(ENABLE_EXPAT OFF)
SET(ENABLE_LIBXML ON)
endif()

if("check" IN_LIST FEATURES)
SET(WITH_CHECK ON)
endif()


if("comp" IN_LIST FEATURES)
SET(ENABLE_COMP ON)
endif()

if("fbc" IN_LIST FEATURES)
SET(ENABLE_FBC ON)
endif()

if("groups" IN_LIST FEATURES)
SET(ENABLE_GROUPS ON)
endif()

if("layout" IN_LIST FEATURES)
SET(ENABLE_LAYOUT ON)
endif()

if("multi" IN_LIST FEATURES)
SET(ENABLE_MULTI ON)
endif()

if("qual" IN_LIST FEATURES)
SET(ENABLE_QUAL ON)
endif()

if("render" IN_LIST FEATURES)
SET(ENABLE_RENDER ON)
SET(ENABLE_LAYOUT ON)
endif()

if ("bzip2" IN_LIST FEATURES)
set(WITH_BZIP2 ON)
endif()

if ("zlib" IN_LIST FEATURES)
set(WITH_ZLIB ON)
endif()

message("

FEATURES = ${FEATURES}


")


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS -DWITH_LIBXML=${ENABLE_LIBXML} -DWITH_EXPAT=${ENABLE_EXPAT} -DENABLE_L3V2EXTENDEDMATH:BOOL=ON
            -DENABLE_COMP=${ENABLE_COMP} -DENABLE_FBC=${ENABLE_FBC} -DENABLE_GROUPS=${ENABLE_GROUPS}
            -DENABLE_LAYOUT=${ENABLE_LAYOUT} -DENABLE_MULTI=${ENABLE_MULTI} -DENABLE_QUAL=${ENABLE_QUAL}
            -DENABLE_RENDER=${ENABLE_RENDER} -DLIBSBML_SKIP_SHARED_LIBRARY=OFF
            -DWITH_ZLIB=${WITH_ZLIB} -DWITH_BZIP2=${WITH_BZIP2} -DWITH_STATIC_RUNTIME=${STATIC_RUNTIME}
            -DWITH_CHECK=${WITH_CHECK}
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${CURRENT_BUILDTREES_DIR}/src/libSBML-5-0f436e5e49/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/libsbml)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libsbml/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/libsbml/copyright)

file(GLOB TXT_FILES ${CURRENT_PACKAGES_DIR}/debug/*.txt)
file(REMOVE ${TXT_FILES})
file(GLOB TXT_FILES ${CURRENT_PACKAGES_DIR}/*.txt)
file(REMOVE ${TXT_FILES})

file(GLOB CMAKE_FILES ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/*-debug.cmake)
file(COPY ${CMAKE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/share/libsbml/cmake)
file(GLOB CMAKE_FILES ${CURRENT_PACKAGES_DIR}/lib/cmake/*.cmake)
file(COPY ${CMAKE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/share/libsbml/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)


# Handle copyright
# file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libsbml RENAME copyright)

# Post-build test for cmake libraries

if (WITH_CHECK)
vcpkg_test_cmake(PACKAGE_NAME libsbml)
endif()

