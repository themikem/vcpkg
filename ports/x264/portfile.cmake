include(vcpkg_common_functions)

set(X264_VERSION 152)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mirror/x264
    REF e9a5903edf8ca59ef20e6f4894c196f135af735e
    SHA512 063da238264b33ab7ccf097c1f8a7d6b1bf1f0777b433ccbb6ab98090f050fa4d289eeff37b701b8fd7fb5ad460b7fa13d61b68b3f397bc78a8eaa50379e4878
    HEAD_REF master
)

# Acquire tools
vcpkg_acquire_msys(MSYS_ROOT PACKAGES make automake1.15)

# Insert msys into the path between the compiler toolset and windows system32. This prevents masking of "link.exe" but DOES mask "find.exe".
string(REPLACE ";$ENV{SystemRoot}\\system32;" ";${MSYS_ROOT}/usr/bin;$ENV{SystemRoot}\\system32;" NEWPATH "$ENV{PATH}")
set(ENV{PATH} "${NEWPATH}")
set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)

set(AUTOMAKE_DIR ${MSYS_ROOT}/usr/share/automake-1.15)
#file(COPY ${AUTOMAKE_DIR}/config.guess ${AUTOMAKE_DIR}/config.sub DESTINATION ${SOURCE_PATH}/source)

set(CONFIGURE_OPTIONS "--host=i686-pc-mingw32 --enable-strip --disable-lavf --disable-swscale --disable-asm --disable-avs --disable-ffms --disable-gpac --disable-lsmash")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(CONFIGURE_OPTIONS_STATIC "${CONFIGURE_OPTIONS} --enable-static")
    set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --enable-shared")

    set(CONFIGURE_OPTIONS_STATIC_RELEASE "--prefix=${CURRENT_PACKAGES_DIR}/static")
    set(CONFIGURE_OPTIONS_STATIC_DEBUG  "--enable-debug --prefix=${CURRENT_PACKAGES_DIR}/debug/static")
else()
    set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --enable-static")
endif()

set(CONFIGURE_OPTIONS_RELEASE "--prefix=${CURRENT_PACKAGES_DIR}")
set(CONFIGURE_OPTIONS_DEBUG  "--enable-debug --prefix=${CURRENT_PACKAGES_DIR}/debug")

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(X264_RUNTIME "-MT")
else()
    set(X264_RUNTIME "-MD")
endif()

# Configure release
message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
set(ENV{CFLAGS} "${X264_RUNTIME} -O2 -Oi -Zi")
set(ENV{CXXFLAGS} "${X264_RUNTIME} -O2 -Oi -Zi")
set(ENV{LDFLAGS} "-DEBUG -INCREMENTAL:NO -OPT:REF -OPT:ICF")
vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc -c 
        "CC=cl ${SOURCE_PATH}/configure ${CONFIGURE_OPTIONS} ${CONFIGURE_OPTIONS_RELEASE}"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
    LOGNAME "configure-${TARGET_TRIPLET}-rel")
message(STATUS "Configuring ${TARGET_TRIPLET}-rel done")

# Configure debug
message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
set(ENV{CFLAGS} "${X264_RUNTIME}d -Od -Zi -RTC1")
set(ENV{CXXFLAGS} "${X264_RUNTIME}d -Od -Zi -RTC1")
set(ENV{LDFLAGS} "-DEBUG")
vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc -c 
        "CC=cl ${SOURCE_PATH}/configure ${CONFIGURE_OPTIONS} ${CONFIGURE_OPTIONS_DEBUG}"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
    LOGNAME "configure-${TARGET_TRIPLET}-dbg")
message(STATUS "Configuring ${TARGET_TRIPLET}-dbg done")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic" AND "staticlib" IN_LIST FEATURES)
    # Configure debug
    message(STATUS "Configuring ${TARGET_TRIPLET}-static-dbg")
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-static-dbg)
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-static-dbg)
    set(ENV{CFLAGS} "${X264_RUNTIME}d -Od -Zi -RTC1")
    set(ENV{CXXFLAGS} "${X264_RUNTIME}d -Od -Zi -RTC1")
    set(ENV{LDFLAGS} "-DEBUG")
    vcpkg_execute_required_process(
        COMMAND ${BASH} --noprofile --norc -c 
            "CC=cl ${SOURCE_PATH}/configure ${CONFIGURE_OPTIONS_STATIC} ${CONFIGURE_OPTIONS_STATIC_DEBUG}"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-static-dbg"
        LOGNAME "configure-${TARGET_TRIPLET}-static-dbg")
    message(STATUS "Configuring ${TARGET_TRIPLET}-static-dbg done")

    # Configure release
    message(STATUS "Configuring ${TARGET_TRIPLET}-static-rel")
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-static-rel)
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-static-rel)
    set(ENV{CFLAGS} "${X264_RUNTIME} -O2 -Oi -Zi")
    set(ENV{CXXFLAGS} "${X264_RUNTIME} -O2 -Oi -Zi")
    set(ENV{LDFLAGS} "-DEBUG -INCREMENTAL:NO -OPT:REF -OPT:ICF")
    vcpkg_execute_required_process(
        COMMAND ${BASH} --noprofile --norc -c 
            "CC=cl ${SOURCE_PATH}/configure ${CONFIGURE_OPTIONS} ${CONFIGURE_OPTIONS_STATIC_RELEASE}"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-static-rel"
        LOGNAME "configure-${TARGET_TRIPLET}-static-rel")
    message(STATUS "Configuring ${TARGET_TRIPLET}-static-rel done")
endif()
    


unset(ENV{CFLAGS})
unset(ENV{CXXFLAGS})
unset(ENV{LDFLAGS})

# Build release
message(STATUS "Package ${TARGET_TRIPLET}-rel")
vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc -c "make && make install"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel"
    LOGNAME "build-${TARGET_TRIPLET}-rel")
message(STATUS "Package ${TARGET_TRIPLET}-rel done")

# Build debug
message(STATUS "Package ${TARGET_TRIPLET}-dbg")
vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc -c "make && make install"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
    LOGNAME "build-${TARGET_TRIPLET}-dbg")
message(STATUS "Package ${TARGET_TRIPLET}-dbg done")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic" AND "staticlib" IN_LIST FEATURES)
    # Build debug
    message(STATUS "Package ${TARGET_TRIPLET}-static-dbg")
    vcpkg_execute_required_process(
        COMMAND ${BASH} --noprofile --norc -c "make && make install"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-static-dbg"
        LOGNAME "build-${TARGET_TRIPLET}-dbg")
    message(STATUS "Package ${TARGET_TRIPLET}-static-dbg done")

    # Build release
    message(STATUS "Package ${TARGET_TRIPLET}-static-rel")
    vcpkg_execute_required_process(
        COMMAND ${BASH} --noprofile --norc -c "make && make install"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-static-rel"
        LOGNAME "build-${TARGET_TRIPLET}-static-rel")
    message(STATUS "Package ${TARGET_TRIPLET}-rel done")
endif()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/x264)
file(COPY ${CURRENT_PACKAGES_DIR}/bin/x264.exe ${CURRENT_PACKAGES_DIR}/tools/x264/)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/lib/pkgconfig
    ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig
    ${CURRENT_PACKAGES_DIR}/static/lib/pkgconfig
    ${CURRENT_PACKAGES_DIR}/debug/static/lib/pkgconfig
    ${CURRENT_PACKAGES_DIR}/debug/bin/x264.exe
    ${CURRENT_PACKAGES_DIR}/debug/static/bin/x264.exe
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/static/include
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/libx264.dll.lib ${CURRENT_PACKAGES_DIR}/lib/libx264.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libx264.dll.lib ${CURRENT_PACKAGES_DIR}/debug/lib/libx264.lib)

    # force U_STATIC_IMPLEMENTATION macro
    file(READ ${CURRENT_PACKAGES_DIR}/static/include/x264.h HEADER_CONTENTS)
    string(REPLACE "defined(U_STATIC_IMPLEMENTATION)" "1" HEADER_CONTENTS "${HEADER_CONTENTS}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/static/include/x264.h "${HEADER_CONTENTS}")
else()
    # force U_STATIC_IMPLEMENTATION macro
    file(READ ${CURRENT_PACKAGES_DIR}/include/x264.h HEADER_CONTENTS)
    string(REPLACE "defined(U_STATIC_IMPLEMENTATION)" "1" HEADER_CONTENTS "${HEADER_CONTENTS}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/x264.h "${HEADER_CONTENTS}")

    file(REMOVE_RECURSE
        ${CURRENT_PACKAGES_DIR}/bin
        ${CURRENT_PACKAGES_DIR}/debug/bin
    )
endif()

vcpkg_copy_pdbs()

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/FindX264.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/x264)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/x264 RENAME copyright)

