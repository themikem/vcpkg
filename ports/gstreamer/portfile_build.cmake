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
#   Build-Depends: glib, pcre, libffi

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

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/gstreamer.patch
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

vcpkg_acquire_msys(MSYS_ROOT PACKAGES git bison mingw-w64-x86_64-pkg-config mingw-w64-x86_64-ninja mingw-w64-x86_64-libxml2 mingw-w64-x86_64-ffmpeg mingw-w64-x86_64-python3 mingw-w64-x86_64-json-glib mingw-w64-x86_64-meson)
set(ENV{PATH} "$ENV{PATH};${MSYS_ROOT}/bin;${MSYS_ROOT}/usr/bin;${MSYS_ROOT}/mingw64/bin;${MSYS_ROOT}/mingw64/usr/bin")

message(STATUS "Got GIT: ${GIT}")
message(STATUS "Got meson: ${MESON_PATH}")
message(STATUS "Got ninja: ${NINJA}")
message(STATUS "Using Python3: ${PYTHON3}")
message(STATUS "PATH: $ENV{PATH}")

vcpkg_apply_patches(
    SOURCE_PATH ${VCPKG_ROOT_DIR}/downloads/tools/msys2/mingw64/include
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/caca0.patch
)

set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)

# set(ENV{LIB} "${CURRENT_INSTALLED_DIR}/lib;$ENV{LIB}")

# vcpkg_configure_meson(SOURCE_PATH "${SOURCE_PATH}")

# message(STATUS "Setting up MSYS2 meson")
# vcpkg_execute_required_process(
#     COMMAND ${BASH} pip3 install meson
#     WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
#     LOGNAME msys2meson-${TARGET_TRIPLET}-dbg
# )

set(BUILD_enable_python false)
if("python" IN_LIST FEATURES)
  set(BUILD_enable_python true)
endif()

set(BUILD_disable_vaapi true)
if("vaapi" IN_LIST FEATURES)
  set(BUILD_disable_vaapi false)
endif()

set(BUILD_disable_gst_devtools true)
if("devtools" IN_LIST FEATURES)
  set(BUILD_disable_gst_devtools false)
endif()

set(BUILD_disable_gstreamer_sharp true)
if("csharp" IN_LIST FEATURES)
  set(BUILD_disable_gstreamer_sharp false)
endif()

set(BUILD_disable_gst_editing_services true)
if("editingsvc" IN_LIST FEATURES)
  set(BUILD_disable_gst_editing_services false)
endif()

set(BUILD_disable_gst_plugins_bad true)
if("badplugins" IN_LIST FEATURES)
  set(BUILD_disable_gst_plugins_bad false)
endif()

set(BUILD_disable_gst_plugins_ugly true)
if("uglyplugins" IN_LIST FEATURES)
  set(BUILD_disable_gst_plugins_ugly false)
endif()

set(BUILD_disable_gtkdoc true)

set(BUILD_library_format "shared")
set(BUILD_disable_examples true)
set(BUILD_disable_gst_debug true)

if(NOT EXISTS "${SOURCE_PATH}/meson/")
    message(STATUS "Setting up meson instance")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone https://github.com/mesonbuild/meson.git
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME meson-${TARGET_TRIPLET}
    )
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    set(BUILD_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)

    file(REMOVE_RECURSE ${BUILD_DIR})
    file(MAKE_DIRECTORY ${BUILD_DIR})

    string(REGEX REPLACE "[/]" "\\\\" PREFIX_DIR ${CURRENT_PACKAGES_DIR})
    message(STATUS "Prefix: ${PREFIX_DIR}")

    set(BUILD_OPTS "--buildtype;release")
    set(BUILD_OPTS "${BUILD_OPTS};--prefix;${PREFIX_DIR}")
    set(BUILD_OPTS "${BUILD_OPTS};-D;enable_python=${BUILD_enable_python}")
    set(BUILD_OPTS "${BUILD_OPTS};-D;disable_gst_devtools=${BUILD_disable_gst_devtools}")
    set(BUILD_OPTS "${BUILD_OPTS};-D;disable_gst_editing_services=${BUILD_disable_gst_editing_services}")
    set(BUILD_OPTS "${BUILD_OPTS};-D;disable_gst_plugins_bad=${BUILD_disable_gst_plugins_bad}")
    set(BUILD_OPTS "${BUILD_OPTS};-D;disable_gst_plugins_ugly=${BUILD_disable_gst_plugins_ugly}")
    set(BUILD_OPTS "${BUILD_OPTS};-D;disable_gstreamer_vaapi=${BUILD_disable_vaapi}")
    set(BUILD_OPTS "${BUILD_OPTS};-D;disable_gstreamer_sharp=${BUILD_disable_gstreamer_sharp}")
    set(BUILD_OPTS "${BUILD_OPTS};-D;gstreamer:library_format=${BUILD_library_format}")
    set(BUILD_OPTS "${BUILD_OPTS};-D;gstreamer:disable_examples=${BUILD_disable_examples}")
    set(BUILD_OPTS "${BUILD_OPTS};-D;gstreamer:disable_gtkdoc=${BUILD_disable_gtkdoc}")
    # set(BUILD_OPTS "${BUILD_OPTS};-D;gstreamer:disable_gst_debug=${BUILD_disable_gst_debug}")

    message(STATUS "Setting up libs & configuring meson")
    vcpkg_execute_required_process(
        COMMAND ${PYTHON3} "${SOURCE_PATH}/msys2_setup.py" --no-error --msys2-path "${MSYS_ROOT}"  --build_dir ${BUILD_DIR} ${BUILD_OPTS} -c pwd
        WORKING_DIRECTORY ${BUILD_DIR}
        LOGNAME buildlibs-${TARGET_TRIPLET}-rel
    )

    message(STATUS "Fixing Python Files")
    vcpkg_execute_required_process(
        COMMAND ${BASH} -c "grep -rl --include *.py 'glib-mkenums' ${CURRENT_BUILDTREES_DIR}/src/gst-build-1.14.0/subprojects | xargs sed -i \"s/arg.endswith('glib-mkenums')/arg.endswith('glib-mkenums.EXE')/g\""
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
        LOGNAME pyfix-${TARGET_TRIPLET}-rel
    )

    # message(STATUS "Running setup")
    # vcpkg_execute_required_process(
    #     COMMAND ${PYTHON3} "${SOURCE_PATH}/setup.py" --no-error --build-dir "${SOURCE_DIR}/../../${TARGET_TRIPLET}-rel" --msys2-path "${MSYS_ROOT}"
    #     WORKING_DIRECTORY ${SOURCE_PATH}
    #     LOGNAME setup-${TARGET_TRIPLET}-rel
    # )

    message(STATUS "Building Release Project")
    vcpkg_execute_required_process(
        COMMAND ${NINJA} -C "${BUILD_DIR}"
        WORKING_DIRECTORY ${BUILD_DIR}
        LOGNAME subproj-${TARGET_TRIPLET}-rel
    )

    # message(STATUS "Running build")
    # vcpkg_execute_required_process(
    #     COMMAND ${NINJA} -C "${BUILD_DIR}"
    #     WORKING_DIRECTORY ${BUILD_DIR}
    #     LOGNAME build-${TARGET_TRIPLET}-rel
    # )

    file(GLOB_RECURSE REL_DLL_FILES LIST_DIRECTORIES false "${BUILD_DIR}/*.dll")
    file(GLOB_RECURSE REL_LIB_FILES LIST_DIRECTORIES false "${BUILD_DIR}/*.lib")
    file(GLOB_RECURSE REL_PDB_FILES LIST_DIRECTORIES false "${BUILD_DIR}/*.pdb")
    file(GLOB_RECURSE REL_EXP_FILES LIST_DIRECTORIES false "${BUILD_DIR}/*.exp")
    file(GLOB_RECURSE REL_ILK_FILES LIST_DIRECTORIES false "${BUILD_DIR}/*.ilk")
    file(GLOB_RECURSE REL_EXE_FILES LIST_DIRECTORIES false "${BUILD_DIR}/*.exe")
    file(GLOB_RECURSE REL_INC_FILES LIST_DIRECTORIES false "${BUILD_DIR}/*.h")

    file(INSTALL ${REL_DLL_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(INSTALL ${REL_PDB_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(INSTALL ${REL_LIB_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(INSTALL ${REL_EXE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
    file(INSTALL ${REL_INC_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

    # message(STATUS "EXE files: ${REL_EXE_FILES}")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    set(BUILD_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)

    file(REMOVE_RECURSE ${BUILD_DIR})
    file(MAKE_DIRECTORY ${BUILD_DIR})

    string(REGEX REPLACE "[/]" "\\\\" PREFIX_DIR "${CURRENT_PACKAGES_DIR}/debug")
    message(STATUS "Prefix: ${PREFIX_DIR}")

    set(BUILD_disable_gst_debug false)

    set(BUILD_OPTS "--buildtype;debug")
    set(BUILD_OPTS "${BUILD_OPTS};--prefix;${PREFIX_DIR}")
    set(BUILD_OPTS "${BUILD_OPTS};-D;enable_python=${BUILD_enable_python}")
    set(BUILD_OPTS "${BUILD_OPTS};-D;disable_gst_devtools=${BUILD_disable_gst_devtools}")
    set(BUILD_OPTS "${BUILD_OPTS};-D;disable_gst_editing_services=${BUILD_disable_gst_editing_services}")
    set(BUILD_OPTS "${BUILD_OPTS};-D;disable_gst_plugins_bad=${BUILD_disable_gst_plugins_bad}")
    set(BUILD_OPTS "${BUILD_OPTS};-D;disable_gst_plugins_ugly=${BUILD_disable_gst_plugins_ugly}")
    set(BUILD_OPTS "${BUILD_OPTS};-D;disable_gstreamer_vaapi=${BUILD_disable_vaapi}")
    set(BUILD_OPTS "${BUILD_OPTS};-D;disable_gstreamer_sharp=${BUILD_disable_gstreamer_sharp}")
    set(BUILD_OPTS "${BUILD_OPTS};-D;gstreamer:library_format=${BUILD_library_format}")
    set(BUILD_OPTS "${BUILD_OPTS};-D;gstreamer:disable_examples=${BUILD_disable_examples}")
    set(BUILD_OPTS "${BUILD_OPTS};-D;gstreamer:disable_gtkdoc=${BUILD_disable_gtkdoc}")
    # set(BUILD_OPTS "${BUILD_OPTS};-D;gstreamer:disable_gst_debug=${BUILD_disable_gst_debug}")


    message(STATUS "Setting up libs & configuring meson")
    vcpkg_execute_required_process(
        COMMAND ${PYTHON3} "${SOURCE_PATH}/msys2_setup.py" --no-error --msys2-path "${MSYS_ROOT}"  --build_dir ${BUILD_DIR} ${BUILD_OPTS} -c pwd
        WORKING_DIRECTORY ${BUILD_DIR}
        LOGNAME buildlibs-${TARGET_TRIPLET}-dbg
    )

    message(STATUS "Fixing Python Files")
    vcpkg_execute_required_process(
        COMMAND ${BASH} -c "grep -rl --include *.py 'glib-mkenums' ${CURRENT_BUILDTREES_DIR}/src/gst-build-1.14.0/subprojects | xargs sed -i \"s/arg.endswith('glib-mkenums')/arg.endswith('glib-mkenums.EXE')/g\""
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
        LOGNAME pyfix-${TARGET_TRIPLET}-rel
    )

    message(STATUS "Building Debug Project")
    vcpkg_execute_required_process(
        COMMAND ${NINJA} -C "${BUILD_DIR}"
        WORKING_DIRECTORY ${BUILD_DIR}
        LOGNAME subproj-${TARGET_TRIPLET}-dbg
    )

    file(GLOB_RECURSE DBG_DLL_FILES LIST_DIRECTORIES false "${BUILD_DIR}/*.dll")
    file(GLOB_RECURSE DBG_LIB_FILES LIST_DIRECTORIES false "${BUILD_DIR}/*.lib")
    file(GLOB_RECURSE DBG_PDB_FILES LIST_DIRECTORIES false "${BUILD_DIR}/*.pdb")
    file(GLOB_RECURSE DBG_EXP_FILES LIST_DIRECTORIES false "${BUILD_DIR}/*.exp")
    file(GLOB_RECURSE DBG_ILK_FILES LIST_DIRECTORIES false "${BUILD_DIR}/*.ilk")
    file(GLOB_RECURSE DBG_EXE_FILES LIST_DIRECTORIES false "${BUILD_DIR}/*.exe")

    file(INSTALL ${DBG_DLL_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(INSTALL ${DBG_PDB_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(INSTALL ${DBG_LIB_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    file(INSTALL ${DBG_EXE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools)

    # message(STATUS "EXE files: ${DBG_EXE_FILES}")
endif()


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



# message(FATAL_ERROR "Shouldn't get here!")

# vcpkg_configure_cmake(
#     SOURCE_PATH ${SOURCE_PATH}
#     PREFER_NINJA # Disable this option if project cannot be built with Ninja
#     # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
#     # OPTIONS_RELEASE -DOPTIMIZE=1
#     # OPTIONS_DEBUG -DDEBUGGABLE=1
# )

# vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/FindGstreamer.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/gstreamer )
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/gstreamer RENAME copyright )
