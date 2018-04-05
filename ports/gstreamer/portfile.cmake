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
set(GSTREAMER_VERSION "1.14.0")
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/gst-build-${GSTREAMER_VERSION})

vcpkg_from_github(
    OUT_SOURCE_PATH ${SOURCE_PATH}
    REPO GStreamer/gst-build
    REF ${GSTREAMER_VERSION}
    SHA512 2f641e2c1ab3010e33de3aa4cbf6121141a35d74848cf436961c5650a602e833a17a28b77a890d4e74d1fc88dd70dbe2e34ed1350b66288f535c4c7a850dbab7
    HEAD_REF master
)

vcpkg_find_acquire_program(NINJA)
vcpkg_find_acquire_program(PYTHON3)
vcpkg_find_acquire_program(MESON)
list(GET MESON 1 MESON_PATH )



get_filename_component(GIT_EXE_PATH ${GIT} DIRECTORY)
get_filename_component(PYTHON3_EXE_PATH ${PYTHON3} DIRECTORY)

get_filename_component(MESON_EXE_PATH ${MESON_PATH} DIRECTORY)
get_filename_component(NINJA_EXE_PATH ${NINJA} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${GIT_EXE_PATH};${NINJA_EXE_PATH};${PYTHON3_EXE_PATH};${MESON_EXE_PATH}")

vcpkg_acquire_msys(MSYS_ROOT git bison mingw-w64-x86_64-pkg-config mingw-w64-x86_64-ninja mingw-w64-x86_64-libxml2 mingw-w64-x86_64-ffmpeg mingw-w64-x86_64-python3 mingw-w64-x86_64-json-glib )
set(ENV{PATH} "$ENV{PATH};${MSYS_ROOT}/bin;${MSYS_ROOT}/usr/bin;${MSYS_ROOT}/mingw64/bin;${MSYS_ROOT}/mingw64/usr/bin")

message(STATUS "Got GIT: ${GIT}")
message(STATUS "Got meson: ${MESON_PATH}")
message(STATUS "Got ninja: ${NINJA}")
message(STATUS "Using Python3: ${PYTHON3}")
message(STATUS "PATH: $ENV{PATH}")

set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)

file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)

# message(STATUS "Setting up MSYS2 meson")
# vcpkg_execute_required_process(
#     COMMAND ${BASH} pip3 install meson
#     WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
#     LOGNAME msys2meson-${TARGET_TRIPLET}-dbg
# )

# message(STATUS "Setting up libs")
# vcpkg_execute_required_process(
#     COMMAND ${PYTHON3} "${SOURCE_PATH}/msys2_setup.py" --msys2-path "${MSYS_ROOT}"
#     WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
#     LOGNAME buildlibs-${TARGET_TRIPLET}-dbg
# )

message(STATUS "Setting up meson")
# vcpkg_execute_required_process(
#     COMMAND ${GIT} clone https://github.com/mesonbuild/meson.git
#     WORKING_DIRECTORY ${SOURCE_PATH}
#     LOGNAME buildlibs-${TARGET_TRIPLET}-dbg
# )
message(STATUS "Running setup")
vcpkg_execute_required_process(
    COMMAND ${PYTHON3} "${SOURCE_PATH}/setup.py" --no-error
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME setup-${TARGET_TRIPLET}-dbg
)
# vcpkg_execute_required_process(
#     COMMAND ${MESON} --werror "${SOURCE_PATH}" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
#     WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
#     LOGNAME build-${TARGET_TRIPLET}-dbg
# )

# vcpkg_execute_required_process(
#     COMMAND ${BASH} --noprofile --norc -c "PATH=/mingw64/bin:/usr/local/bin:/usr/bin:/bin:$PATH meson --werror ${SOURCE_PATH} ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
#     WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
#     LOGNAME buildmsys2-${TARGET_TRIPLET}-dbg
# )


# vcpkg_acquire_msys(MSYS_ROOT)

message(STATUS "Running build")
vcpkg_execute_required_process(
    COMMAND ${NINJA} -C "${SOURCE_PATH}/build"
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME build-${TARGET_TRIPLET}-dbg
)

message(FATAL_ERROR "Shouldn't get here!")

# vcpkg_configure_cmake(
#     SOURCE_PATH ${SOURCE_PATH}
#     PREFER_NINJA # Disable this option if project cannot be built with Ninja
#     # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
#     # OPTIONS_RELEASE -DOPTIMIZE=1
#     # OPTIONS_DEBUG -DDEBUGGABLE=1
# )

# vcpkg_install_cmake()

# Handle copyright
# file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/gstreamer RENAME copyright)
