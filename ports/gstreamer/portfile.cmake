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

include(vcpkg_common_functions)
set(GSTREAMER_REQUIRED_VERSION "1.14.0")

if(VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
    set(ARCH "x86_64")
else()
    set(ARCH "x86")
endif()

# Due to the complexity involved, this package doesn't install CUDA. It instead verifies that CUDA is installed.
# Other packages can depend on this package to declare a dependency on CUDA.
# If this package is installed, we assume that CUDA is properly installed.

find_program(GST_LAUNCH
    NAMES gst-launch gst-launch-1.0.exe
    PATHS
      ENV GST_PLUGIN_PATH
      $ENV{HOMEDRIVE}/$ENV{HOMEFOLDER}/.gstreamer-1.0
      $ENV{HOMEDRIVE}/gstreamer/1.0/${ARCH}
    PATH_SUFFIXES bin bin64
    DOC "Gstreamer location."
    NO_DEFAULT_PATH
    )

set(error_code 1)
if (GST_LAUNCH)
    execute_process(
        COMMAND ${GST_LAUNCH} --version
        OUTPUT_VARIABLE GST_OUTPUT
        RESULT_VARIABLE error_code)
endif()

set(GST_REQUIRED_VERSION "1.14.0")

if (error_code)
    message(FATAL_ERROR "Could not find Gstreamer. Before continuing, please download and install Gstreamer binaries and development files\n(${GSTREAMER_REQUIRED_VERSION} or higher) from:"
                        "\n    https://gstreamer.freedesktop.org/data/pkg/windows/\n"
                        "\nAlso ensure vcpkg has been rebuilt with the latest version (v0.0.104 or later)")
endif()

# Sample output:
# gst-launch-1.0 version 1.14.0
# GStreamer 1.14.0
# Unknown package origin
string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)" GST_VERSION ${GST_OUTPUT})
set(GST_VERSION_MAJOR ${CMAKE_MATCH_1})
set(GST_VERSION_MINOR ${CMAKE_MATCH_2})
set(GST_VERSION_PATCH ${CMAKE_MATCH_3})

message(STATUS "Found GST ${GST_VERSION} - ${GST_VERSION_MAJOR}.${GST_VERSION_MINOR}.${GST_VERSION_PATCH}")

if (GST_VERSION_MAJOR LESS 1 OR GST_VERSION_MINOR LESS 14)
    message(FATAL_ERROR "Gstreamer ${GST_VERSION} but ${GSTREAMER_REQUIRED_VERSION} is required. Please download and install a more recent version from:"
                        "\n    https://gstreamer.freedesktop.org/data/pkg/windows/\n")
endif()

# message(FATAL_ERROR "Shouldn't be here!")

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/FindGstreamer.cmake DESTINATION ${CURRENT_INSTALLED_DIR}/share/gstreamer)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/FindGstreamerWindows.cmake DESTINATION ${CURRENT_INSTALLED_DIR}/share/gstreamer)

SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)