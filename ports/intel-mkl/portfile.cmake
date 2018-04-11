# Due to the complexity involved, this package doesn't install MKL. It instead verifies that MKL is installed.
# Other packages can depend on this package to declare a dependency on MKL.
# If this package is installed, we assume that MKL is properly installed.

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(MKL_REQUIRED_VERSION "20180000")

set(ARCH_TYPE "intel64")

set(ProgramFilesx86 "ProgramFiles(x86)")
set(INTEL_ROOT $ENV{${ProgramFilesx86}}/IntelSWTools/compilers_and_libraries/windows)

find_path(MKL_ROOT include/mkl.h PATHS $ENV{MKLROOT} ${INTEL_ROOT}/mkl DOC "Folder contains MKL")

if (MKL_ROOT STREQUAL "MKL_ROOT-NOTFOUND")
    message(FATAL_ERROR "Could not find MKL. Before continuing, please download and install MKL  (${MKL_REQUIRED_VERSION} or higher) from:"
                        "\n    https://registrationcenter.intel.com/en/products/download/3178/\n"
                        "\nAlso ensure vcpkg has been rebuilt with the latest version (v0.0.104 or later)")
endif()

# file(STRINGS ${MKL_ROOT}/include/mkl_version.h MKL_VERSION_DEFINITION REGEX "__INTEL_MKL((_MINOR)|(_UPDATE))?__")
# string(REGEX MATCHALL "([0-9]+)" MKL_VERSION ${MKL_VERSION_DEFINITION})
# list(GET MKL_VERSION 0 MKL_VERSION_MAJOR)
# list(GET MKL_VERSION 1 MKL_VERSION_MINOR)
# list(GET MKL_VERSION 2 MKL_VERSION_UPDATE)

file(STRINGS ${MKL_ROOT}/include/mkl_version.h MKL_VERSION_DEFINITION REGEX "INTEL_MKL_VERSION")
string(REGEX MATCH "([0-9]+)" MKL_VERSION ${MKL_VERSION_DEFINITION})

if (MKL_VERSION LESS MKL_REQUIRED_VERSION)
    message(FATAL_ERROR "MKL ${MKL_VERSION} is found but ${MKL_REQUIRED_VERSION} is required. Please download and install a more recent version of MKL from:"
                        "\n    https://registrationcenter.intel.com/en/products/download/3178/\n")
endif()

get_filename_component(ARCH_PATH "${INTEL_ROOT}/redist/${ARCH_TYPE}" REALPATH)

file(GLOB MKL_DLL_FILES "${ARCH_PATH}/mkl/*.dll")
file(GLOB MKL_COMP_DLL_FILES "${ARCH_PATH}/compiler/*.dll")

message(STATUS "path - ${ARCH_PATH}/mkl - glob ${MKL_DLL_FILES}")

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
file(INSTALL ${MKL_DLL_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(INSTALL ${MKL_COMP_DLL_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/intel-mkl)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/FindMKL.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/intel-mkl)
file(INSTALL $ENV{${ProgramFilesx86}}/IntelSWTools/compilers_and_libraries/licensing/mkl/en/license.rtf DESTINATION ${CURRENT_PACKAGES_DIR}/share/intel-mkl)