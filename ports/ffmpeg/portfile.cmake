include(vcpkg_common_functions)

set(FFMPEG_PORT_VERSION "3.4.2")

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/ffmpeg-${FFMPEG_PORT_VERSION})

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FFmpeg/FFmpeg
    REF n${FFMPEG_PORT_VERSION}
    SHA512 68686b797d770f4550e1fa220332fac23aed5e6daa77c265b46206601335f530ad502706473e23ef203aeabfa2a79bee552b77f7929f43226c1dc55c47dac56b
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/create-lib-libraries.patch
        ${CMAKE_CURRENT_LIST_DIR}/detect-openssl.patch
        ${CMAKE_CURRENT_LIST_DIR}/configure_opencv.patch
)

vcpkg_find_acquire_program(YASM)
get_filename_component(YASM_EXE_PATH ${YASM} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${YASM_EXE_PATH}")

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES perl gcc diffutils make)
else()
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES diffutils make)
endif()
set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)
set(ENV{INCLUDE} "${CURRENT_INSTALLED_DIR}/include;$ENV{INCLUDE}")
set(ENV{LIB} "${CURRENT_INSTALLED_DIR}/lib;$ENV{LIB}")

set(_csc_PROJECT_PATH ffmpeg)

file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)

set(OPTIONS "--enable-asm --enable-yasm --disable-doc --disable-ffmpeg --target-os=win32")
set(OPTIONS "${OPTIONS} --enable-runtime-cpudetect")

message(STATUS "VCPKG_TARGET_ARCHITECTURE=${VCPKG_TARGET_ARCHITECTURE}")
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(OPTIONS "${OPTIONS} --arch=x86_64")
else()
    set(OPTIONS "${OPTIONS} --arch=${VCPKG_TARGET_ARCHITECTURE}")
endif()

if("nonfree" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-nonfree")
endif()

if("gpl" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-gpl")
endif()

if("openssl" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-openssl")
else()
    set(OPTIONS "${OPTIONS} --disable-openssl")
endif()

if("ffplay" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-ffplay")
else()
    set(OPTIONS "${OPTIONS} --disable-ffplay")
endif()

if("ffserver" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-ffserver")
else()
    set(OPTIONS "${OPTIONS} --disable-ffserver")
endif()

if("ffprobe" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-ffprobe")
else()
    set(OPTIONS "${OPTIONS} --disable-ffprobe")
endif()

if("x264" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-libx264")
else()
    set(OPTIONS "${OPTIONS} --disable-libx264")
endif()

if("opencl" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-opencl")
else()
    set(OPTIONS "${OPTIONS} --disable-opencl")
endif()

if("lzma" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-lzma")
else()
    set(OPTIONS "${OPTIONS} --disable-lzma")
endif()

# bzip2's debug library is named "bz2d", which isn't found by ffmpeg
# if("bzip2" IN_LIST FEATURES)
#     set(OPTIONS "${OPTIONS} --enable-bzip2")
# else()
#     set(OPTIONS "${OPTIONS} --disable-bzip2")
# endif()

if("avresample" IN_LIST FEATURES)
    set(OPTIONS "${OPTIONS} --enable-avresample")
endif()

if("cuda" IN_LIST FEATURES)
    find_program(NVCC
        NAMES nvcc nvcc.exe
        PATHS
        ENV CUDA_PATH
        ENV CUDA_BIN_PATH
        PATH_SUFFIXES bin bin64
        DOC "Toolkit location."
        NO_DEFAULT_PATH
    )
    
    if(NVCC)
        set(CUDA_FOUND TRUE)
        set(CUDA_TOOLKIT_ROOT_DIR $ENV{CUDA_PATH})
        message(STATUS "PATH - ${CUDA_TOOLKIT_ROOT_DIR} / NVCC - ${NVCC}")
        # list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")
        # find_package(CUDA REQUIRED)
        set(ENV{INCLUDE} "${CURRENT_INSTALLED_DIR}/include;${CUDA_TOOLKIT_ROOT_DIR}/include;$ENV{INCLUDE}")
        set(ENV{LIB} "${CURRENT_INSTALLED_DIR}/lib;${CUDA_TOOLKIT_ROOT_DIR}/lib/x64;$ENV{LIB}")
    endif()

    if(CUDA_FOUND)
        set(OPTIONS "${OPTIONS} --enable-cuda --enable-cuvid --enable-nvenc --enable-libnpp")
    endif()
endif()

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(ENV{LIBPATH} "$ENV{LIBPATH};$ENV{_WKITS10}references\\windows.foundation.foundationcontract\\2.0.0.0\\;$ENV{_WKITS10}references\\windows.foundation.universalapicontract\\3.0.0.0\\")
    set(OPTIONS "${OPTIONS} --disable-programs --enable-cross-compile")
    set(OPTIONS "${OPTIONS} --extra-cflags=-DWINAPI_FAMILY=WINAPI_FAMILY_APP --extra-cflags=-D_WIN32_WINNT=0x0A00")

    if (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
        vcpkg_find_acquire_program(GASPREPROCESSOR)
        foreach(GAS_PATH ${GASPREPROCESSOR})
            get_filename_component(GAS_ITEM_PATH ${GAS_PATH} DIRECTORY)
            set(ENV{PATH} "$ENV{PATH};${GAS_ITEM_PATH}")
        endforeach(GAS_PATH)
    elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    else()
        message(FATAL_ERROR "Unsupported architecture")
    endif()
endif()

set(OPTIONS_DEBUG "--enable-debug") # Note: --disable-optimizations can't be used due to http://ffmpeg.org/pipermail/libav-user/2013-March/003945.html
set(OPTIONS_RELEASE "")

set(OPTIONS "${OPTIONS} --extra-cflags=-DHAVE_UNISTD_H=0 --enable-w32threads")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    if("staticlibs" IN_LIST FEATURES)
        set(OPTIONS_STATIC "${OPTIONS} --enable-static --disable-shared")
        set(OPTIONS_STATIC_DEBUG "${OPTIONS_DEBUG} --extra-cflags=-MTd --extra-cxxflags=-MTd")
        set(OPTIONS_STATIC_RELEASE "${OPTIONS_RELEASE} --extra-cflags=-MT --extra-cxxflags=-MT")
    endif()
    
    set(OPTIONS "${OPTIONS} --disable-static --enable-shared")
    if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        set(OPTIONS "${OPTIONS} --extra-ldflags=-APPCONTAINER --extra-ldflags=WindowsApp.lib")
    endif()
endif()

if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    set(OPTIONS_DEBUG "${OPTIONS_DEBUG} --extra-cflags=-MDd --extra-cxxflags=-MDd")
    set(OPTIONS_RELEASE "${OPTIONS_RELEASE} --extra-cflags=-MD --extra-cxxflags=-MD")
else()
    set(OPTIONS_DEBUG "${OPTIONS_DEBUG} --extra-cflags=-MTd --extra-cxxflags=-MTd")
    set(OPTIONS_RELEASE "${OPTIONS_RELEASE} --extra-cflags=-MT --extra-cxxflags=-MT")
endif()

message(STATUS "Building ${_csc_PROJECT_PATH} for Debug")
message(STATUS "OPTIONS - ${OPTIONS}")
message(STATUS "OPTIONS_DEBUG - ${OPTIONS_DEBUG}")
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc "${CMAKE_CURRENT_LIST_DIR}\\build.sh"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg" # BUILD DIR
        "${SOURCE_PATH}" # SOURCE DIR
        "${CURRENT_PACKAGES_DIR}/debug" # PACKAGE DIR
        "${OPTIONS} ${OPTIONS_DEBUG}"
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
    LOGNAME build-${TARGET_TRIPLET}-dbg
)

message(STATUS "Building ${_csc_PROJECT_PATH} for Release")
message(STATUS "OPTIONS - ${OPTIONS}")
message(STATUS "OPTIONS_RELEASE - ${OPTIONS_RELEASE}")
file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc "${CMAKE_CURRENT_LIST_DIR}\\build.sh"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel" # BUILD DIR
        "${SOURCE_PATH}" # SOURCE DIR
        "${CURRENT_PACKAGES_DIR}" # PACKAGE DIR
        "${OPTIONS} ${OPTIONS_RELEASE}"
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
    LOGNAME build-${TARGET_TRIPLET}-rel
)



if("staticlibs" IN_LIST FEATURES)
    if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
        message(STATUS "Building ${_csc_PROJECT_PATH} for Static Debug Libs")
        message(STATUS "OPTIONS_STATIC - ${OPTIONS_STATIC}")
        message(STATUS "OPTIONS_STATIC_DEBUG - ${OPTIONS_STATIC_DEBUG}")
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-static-dbg)
        vcpkg_execute_required_process(
            COMMAND ${BASH} --noprofile --norc "${CMAKE_CURRENT_LIST_DIR}\\build.sh"
                "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-static-dbg" # BUILD DIR
                "${SOURCE_PATH}" # SOURCE DIR
                "${CURRENT_PACKAGES_DIR}/debug/static" # PACKAGE DIR
                "${OPTIONS_STATIC} ${OPTIONS_STATIC_DEBUG}"
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-static-dbg
            LOGNAME build-${TARGET_TRIPLET}-static-dbg
        )

        message(STATUS "Building ${_csc_PROJECT_PATH} for Static Release Libs")
        message(STATUS "OPTIONS_STATIC - ${OPTIONS_STATIC}")
        message(STATUS "OPTIONS_STATIC_RELEASE - ${OPTIONS_STATIC_RELEASE}")
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-static-rel)
        vcpkg_execute_required_process(
            COMMAND ${BASH} --noprofile --norc "${CMAKE_CURRENT_LIST_DIR}\\build.sh"
                "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-static-rel" # BUILD DIR
                "${SOURCE_PATH}" # SOURCE DIR
                "${CURRENT_PACKAGES_DIR}/static" # PACKAGE DIR
                "${OPTIONS_STATIC} ${OPTIONS_STATIC_RELEASE}"
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-static-rel
            LOGNAME build-${TARGET_TRIPLET}-static-rel
        )
    else()
        message(STATUS "Static files already built - copying to package output dir")
        message(STATUS "Building ${_csc_PROJECT_PATH} for Static Debug Libs")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/static")
        file(GLOB STATIC_DEBUG_LIB_FILES "${CURRENT_PACKAGES_DIR}/debug/lib/*.lib")
        foreach(STATIC_DEBUG_LIB_FILE ${STATIC_DEBUG_LIB_FILES})
            file(COPY STATIC_DEBUG_LIB_FILE DESTINATION ${CURRENT_PACKAGES_DIR}/debug/static/lib)
        endforeach()

        message(STATUS "Building ${_csc_PROJECT_PATH} for Static Release Libs")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/static")
        file(GLOB STATIC_LIB_FILES "${CURRENT_PACKAGES_DIR}/lib/*.lib")
        foreach(STATIC_LIB_FILE ${STATIC_LIB_FILES})
            file(COPY STATIC_LIB_FILE DESTINATION ${CURRENT_PACKAGES_DIR}/static/lib)
        endforeach()
    endif()
endif()

file(GLOB DEF_FILES ${CURRENT_PACKAGES_DIR}/lib/*.def ${CURRENT_PACKAGES_DIR}/debug/lib/*.def)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    set(LIB_MACHINE_ARG /machine:ARM)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(LIB_MACHINE_ARG /machine:x86)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(LIB_MACHINE_ARG /machine:x64)
else()
    message(FATAL_ERROR "Unsupported target architecture")
endif()

foreach(DEF_FILE ${DEF_FILES})
    get_filename_component(DEF_FILE_DIR "${DEF_FILE}" DIRECTORY)
    get_filename_component(DEF_FILE_NAME "${DEF_FILE}" NAME)
    string(REGEX REPLACE "-[0-9]*\\.def" ".lib" OUT_FILE_NAME "${DEF_FILE_NAME}")
    file(TO_NATIVE_PATH "${DEF_FILE}" DEF_FILE_NATIVE)
    file(TO_NATIVE_PATH "${DEF_FILE_DIR}/${OUT_FILE_NAME}" OUT_FILE_NATIVE)
    message(STATUS "Generating ${OUT_FILE_NATIVE}")
    vcpkg_execute_required_process(
        COMMAND lib.exe /def:${DEF_FILE_NATIVE} /out:${OUT_FILE_NATIVE} ${LIB_MACHINE_ARG}
        WORKING_DIRECTORY ${CURRENT_PACKAGES_DIR}
        LOGNAME libconvert-${TARGET_TRIPLET}
    )
endforeach()

file(GLOB EXP_FILES ${CURRENT_PACKAGES_DIR}/lib/*.exp ${CURRENT_PACKAGES_DIR}/debug/lib/*.exp)
file(GLOB LIB_FILES ${CURRENT_PACKAGES_DIR}/bin/*.lib ${CURRENT_PACKAGES_DIR}/debug/bin/*.lib)
file(GLOB EXE_FILES ${CURRENT_PACKAGES_DIR}/bin/*.exe ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
set(FILES_TO_REMOVE ${EXP_FILES} ${LIB_FILES} ${DEF_FILES} ${EXE_FILES})
list(LENGTH FILES_TO_REMOVE FILES_TO_REMOVE_LEN)
if(FILES_TO_REMOVE_LEN GREATER 0)
    file(REMOVE ${FILES_TO_REMOVE})
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share ${CURRENT_PACKAGES_DIR}/debug/static/include ${CURRENT_PACKAGES_DIR}/static/include)

vcpkg_copy_pdbs()

# Handle copyright
# TODO: Examine build log and confirm that this license matches the build output
file(COPY ${SOURCE_PATH}/COPYING.LGPLv2.1 DESTINATION ${CURRENT_PACKAGES_DIR}/share/ffmpeg)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/ffmpeg/COPYING.LGPLv2.1 ${CURRENT_PACKAGES_DIR}/share/ffmpeg/copyright)

# Used by OpenCV
file(COPY ${CMAKE_CURRENT_LIST_DIR}/FindFFMPEG.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/ffmpeg)
