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

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	BRANCH "master"
	REPO "google/leveldb"
	REF "18683981505dc374ce29211c80a9552f8f2f4571"
    SHA512 2b5c53d86fff1c9a8718276a483ac192d08a01304e6352d2aa6168116b8cb303a9f0116115da406300ebdb8fb17f77d048477e706b664a618dd509bc8e97bc55
)

set(LEVELDB_BUILD_TESTS OFF)
set(LEVELDB_BUILD_BENCHMARKS OFF)

set(WINDOWS_PORT_FILES
    ${CMAKE_CURRENT_LIST_DIR}/port_win.h
    ${CMAKE_CURRENT_LIST_DIR}/port_win.cc
)

set(WINDOWS_UTIL_FILES
    ${CMAKE_CURRENT_LIST_DIR}/env_win.cc
)

vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/windows_port.patch
)

file(COPY ${WINDOWS_PORT_FILES} DESTINATION ${SOURCE_PATH}/port)
file(COPY ${WINDOWS_UTIL_FILES} DESTINATION ${SOURCE_PATH}/util)

list(APPEND CMAKE_MODULE_PATH ${CURRENT_INSTALLED_DIR}/share/snappy)
list(APPEND CMAKE_MODULE_PATH ${CURRENT_INSTALLED_DIR}/share/crc32c)
	
message(STATUS "Configuring with options:")
message(STATUS "  - LEVELDB_BUILD_TESTS: ${LEVELDB_BUILD_TESTS}")
message(STATUS "  - LEVELDB_BUILD_BENCHMARKS: ${LEVELDB_BUILD_BENCHMARKS}")

string(REPLACE ";" "\\\\\;" CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}")

set(ENV{LIB} "${CURRENT_INSTALLED_DIR}/lib;$ENV{LIB}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
    "-DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}"
    -DLEVELDB_BUILD_TESTS=${LEVELDB_BUILD_TESTS}
    -DLEVELDB_BUILD_BENCHMARKS=${LEVELDB_BUILD_BENCHMARKS}
    -DCMAKE_INSTALL_DATADIR=share/leveldb
    "-DCMAKE_INSTALL_FULL_DATADIR=${CURRENT_PACKAGES_DIR}/share/leveldb"
)

vcpkg_install_cmake()

file(GLOB EXE_FILES LIST_DIRECTORIES false ${CURRENT_PACKAGES_DIR}/bin/*.exe)
file(GLOB DEBUG_EXE_FILES LIST_DIRECTORIES false ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
file(GLOB DEBUG_SHARE_CMAKE_FILES LIST_DIRECTORIES false ${CURRENT_PACKAGES_DIR}/debug/share/leveldb/*.cmake)

file(INSTALL ${EXE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/leveldb)
file(INSTALL ${DEBUG_EXE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/leveldb)

if(DEBUG_SHARE_CMAKE_FILES)
    file(INSTALL ${DEBUG_SHARE_CMAKE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/share/leveldb)
endif()

file(REMOVE ${EXE_FILES})
file(REMOVE ${DEBUG_EXE_FILES})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share/bin)

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/FindLeveldb.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/leveldb)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/leveldb RENAME copyright)
