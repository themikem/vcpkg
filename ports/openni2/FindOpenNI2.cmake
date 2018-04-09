### FindOpenNI2 CMake Script
# Sets expected OpenNI2 environment variables from downloadable package to
#   match VCPKG paths

if("${CMAKE_SIZEOF_VOID_P}" STREQUAL "8")
    # message(STATUS "FINDING OPENNI2 x64")
    if(CMAKE_BUILD_TYPE MATCHES DEBUG)
        set(ENV{OPENNI2_LIB64} "${CURRENT_INSTALLED_DIR}/debug/lib")
    else()
        set(ENV{OPENNI2_LIB64} "${CURRENT_INSTALLED_DIR}/lib")
    endif()
    set(ENV{OPENNI2_INCLUDE64} "${CURRENT_INSTALLED_DIR}/include/openni2")
    # message(STATUS "FindOpenNI2 ENV - $ENV{OPENNI2_LIB64} / $ENV{OPENNI2_INCLUDE64}")
else()
    # message(STATUS "FINDING OPENNI2 x32")
    if(CMAKE_BUILD_TYPE MATCHES DEBUG)
        set(ENV{OPENNI2_LIB} "${CURRENT_INSTALLED_DIR}/debug/lib")
    else()
        set(ENV{OPENNI2_LIB} "${CURRENT_INSTALLED_DIR}/lib")
    endif()
    set(ENV{OPENNI2_INCLUDE} "${CURRENT_INSTALLED_DIR}/include/openni2")
    # message(STATUS "FindOpenNI2 ENV - $ENV{OPENNI2_LIB} / $ENV{OPENNI2_INCLUDE}")
endif()

set(OPENNI2_FOUND TRUE)
