if (VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
    message(FATAL_ERROR "Caffe cannot be built for the x86 architecture")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO willyd/caffe
    REF 0fadeb5d25b27f9f835590153c20f8578c478f0d
    SHA512 1fb9e008651a4cb5c34e3005ff07a49f2d661aa2a9f4ba8439f3dc899b4ad9020f437a4f9085d2db318ef0186c2ca8f96533a9c6cb620b7868493e770180f370
    HEAD_REF windows
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
      "${CMAKE_CURRENT_LIST_DIR}/0001-protobuf-cmake-use-vcpkg.patch"
      "${CMAKE_CURRENT_LIST_DIR}/0002-fix-config-if-statements.patch"
      "${CMAKE_CURRENT_LIST_DIR}/0003-enable-snappy.patch"
)

#core Build-Depends
list(APPEND CMAKE_MODULE_PATH ${CURRENT_INSTALLED_DIR}/share/gflags)
list(APPEND CMAKE_MODULE_PATH ${CURRENT_INSTALLED_DIR}/share/glog)
list(APPEND CMAKE_MODULE_PATH ${CURRENT_INSTALLED_DIR}/share/hdf5)
list(APPEND CMAKE_MODULE_PATH ${CURRENT_INSTALLED_DIR}/share/protobuf)
list(APPEND CMAKE_MODULE_PATH ${CURRENT_INSTALLED_DIR}/share/openblas)

if("cuda" IN_LIST FEATURES)
    set(CPU_ONLY OFF)
    list(APPEND CMAKE_MODULE_PATH ${CURRENT_INSTALLED_DIR}/share/cuda)
    # find_package(cuda REQUIRED)
else()
    set(CPU_ONLY ON)
endif()

if("mkl" IN_LIST FEATURES)
    set(BLAS MKL)
    list(APPEND CMAKE_MODULE_PATH ${CURRENT_INSTALLED_DIR}/share/intel-mkl)
else()
    set(BLAS Open)
endif()

if("opencv" IN_LIST FEATURES)
    set(USE_OPENCV ON)
    list(APPEND CMAKE_MODULE_PATH ${CURRENT_INSTALLED_DIR}/share/opencv)
    # find_package(OpenCV REQUIRED)
else()
    set(USE_OPENCV OFF)
endif()

if("lmdb" IN_LIST FEATURES)
    set(USE_LMDB ON)
    list(APPEND CMAKE_MODULE_PATH ${CURRENT_INSTALLED_DIR}/share/lmdb)
else()
    set(USE_LMDB OFF)
endif()

if("leveldb" IN_LIST FEATURES)
    set(USE_LEVELDB ON)
    list(APPEND CMAKE_MODULE_PATH ${CURRENT_INSTALLED_DIR}/share/leveldb)
    list(APPEND CMAKE_MODULE_PATH ${CURRENT_INSTALLED_DIR}/share/snappy)
else()
    set(USE_LEVELDB OFF)
endif()

if("python3" IN_LIST FEATURES)
    set(BUILD_python ON)
else()
    set(BUILD_python OFF)
endif()

string(REPLACE ";" "\\\\\;" CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}")

vcpkg_configure_cmake(
    PREFER_NINJA
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
    "-DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}"
    -DCOPY_PREREQUISITES=OFF
    -DINSTALL_PREREQUISITES=OFF
    # Set to ON to use python
    -DBUILD_python=${BUILD_python}
    -DBUILD_python_layer=OFF
    -Dpython_version=3.6
    -DBUILD_matlab=OFF
    -DBUILD_docs=OFF
    -DBLAS=${BLAS}
    -DCPU_ONLY=${CPU_ONLY}
    -DBUILD_TEST=OFF
    -DUSE_LEVELDB=${USE_LEVELDB}
    -DUSE_OPENCV=${USE_OPENCV}
    -DUSE_LMDB=${USE_LMDB}
    -DUSE_NCCL=OFF
    
)

vcpkg_install_cmake()

# Move bin to tools
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/caffe)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/share/caffe)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/tools)
file(GLOB BINARIES ${CURRENT_PACKAGES_DIR}/bin/*.exe)
foreach(binary ${BINARIES})
    get_filename_component(binary_name ${binary} NAME)
    file(RENAME ${binary} ${CURRENT_PACKAGES_DIR}/tools/${binary_name})
endforeach()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/python)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/python)

file(GLOB DEBUG_BINARIES ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
foreach(binary ${DEBUG_BINARIES})
    get_filename_component(binary_name ${binary} NAME)
    file(RENAME ${binary} ${CURRENT_PACKAGES_DIR}/debug/tools/${binary_name})
endforeach()

file(READ ${CURRENT_PACKAGES_DIR}/debug/share/caffe/caffetargets-debug.cmake CAFFE_DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" CAFFE_DEBUG_MODULE "${CAFFE_DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/caffe/caffetargets-debug.cmake "${CAFFE_DEBUG_MODULE}")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/FindCaffe.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/caffe)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/caffe RENAME copyright)

vcpkg_copy_pdbs()
