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

set(GITHUB_CURRENT_REF "d6214653740d8100658a6e4d224f94d3c4c673e1")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CMU-Perceptual-Computing-Lab/openpose
    REF ${GITHUB_CURRENT_REF}
    SHA512 0b32559c1257f6f299327cf478c5031d7be60b13007a792460956dbec717680eac518317fd9bd52ae81907f8d5d1aee33c619c112aea51fb296921fdb1042494
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/windows-fixes.patch
)

# set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/openpose-1.2.1)
# vcpkg_download_distfile(ARCHIVE
#     URLS "https://github.com/CMU-Perceptual-Computing-Lab/openpose/archive/v1.2.1.zip"
#     FILENAME "openpose-v1-2-1.zip"
#     SHA512 7352911fc5a5f8e69a9a9b034ffa64ec8642a0ba181b6b563c39e76491afe34e8ca02fedc1db71347f41bd2b270428c910d9832735da557775c23d5a66331895
# )
# vcpkg_extract_source_archive(${ARCHIVE})

list(APPEND CMAKE_MODULE_PATH ${CURRENT_INSTALLED_DIR}/share/glog)
list(APPEND CMAKE_MODULE_PATH ${CURRENT_INSTALLED_DIR}/share/gflags)
list(APPEND CMAKE_MODULE_PATH ${CURRENT_INSTALLED_DIR}/share/opencv)
list(APPEND CMAKE_MODULE_PATH ${CURRENT_INSTALLED_DIR}/share/caffe)

if("opencl" IN_LIST FEATURES)
    set(GPU_MODE "OPENCL")
else()
    set(GPU_MODE "CPU_ONLY")
endif()

if("cuda" IN_LIST FEATURES)
    set(GPU_MODE "CUDA")
else()
    set(GPU_MODE "CPU_ONLY")
endif()

if("mkl" IN_LIST FEATURES)
    set(USE_MKL ON)
else()
    if(GPU_MODE MATCHES "CPU_ONLY")
        set(USE_MKL ON)
    else()
        set(USE_MKL OFF)
    endif()
endif()

if("examples" IN_LIST FEATURES)
    set(BUILD_EXAMPLES ON)
else()
    set(BUILD_EXAMPLES OFF)
endif()

if("3drenderer" IN_LIST FEATURES)
    set(3D_RENDERER ON)
else()
    set(3D_RENDERER OFF)
endif()

if("flircam" IN_LIST FEATURES)
    set(FLIR_CAMERA ON)
else()
    set(FLIR_CAMERA OFF)
endif()

if("profiler" IN_LIST FEATURES)
    set(PROFILER ON)
else()
    set(PROFILER OFF)
endif()

#GPU_MODE
#PROFILER_ENABLED
#BUILD_DOCS
#BUILD_EXAMPLES
#USE_MKL
#USE_CUDNN


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
    OPTIONS
    -DBUILD_SHARED_LIBS=0
    "-DCURRENT_INSTALLED_DIR=${CURRENT_INSTALLED_DIR}"
    "-DCURRENT_PACKAGES_DIR=${CURRENT_PACKAGES_DIR}"
    -DVCPKG_TARGET_ARCHITECTURE=${VCPKG_TARGET_ARCHITECTURE}
    -DGPU_MODE=${GPU_MODE}
    -DWITH_3D_RENDERER=${3D_RENDERER}
    -DWITH_FLIR_CAMERA=${FLIR_CAMERA}
    -DUSE_MKL=${USE_MKL}
    -DBUILD_DOCS=OFF
    -DBUILD_EXAMPLES=${BUILD_EXAMPLES}
    -DPROFILER_ENABLED=${PROFILER}
)

vcpkg_install_cmake()

message(STATUS "Installing into dir - ${CURRENT_PACKAGES_DIR}")

file(COPY ${CURRENT_BUILDTREES_DIR}/src/openpose-${GITHUB_CURRENT_REF}/include DESTINATION ${CURRENT_PACKAGES_DIR})
file(COPY ${CURRENT_BUILDTREES_DIR}/src/openpose-${GITHUB_CURRENT_REF}/models DESTINATION ${CURRENT_PACKAGES_DIR}/tools/openpose)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(COPY ${CURRENT_BUILDTREES_DIR}/src/openpose-${GITHUB_CURRENT_REF}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/openpose)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/openpose/LICENSE ${CURRENT_PACKAGES_DIR}/share/openpose/copyright)

# Handle copyright
# file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/openpose RENAME copyright)
