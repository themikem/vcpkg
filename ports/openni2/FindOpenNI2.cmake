### FindOpenNI2 CMake Script
# Sets expected OpenNI2 environment variables from downloadable package to
#   match VCPKG paths

get_filename_component(CURRENT_INSTALLED_DIR "../../" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_LIST_DIR}")
message(STATUS "Finding VCPKG OpenNI2 in ${CURRENT_INSTALLED_DIR}")

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

if(WIN32)
    if("${CMAKE_SIZEOF_VOID_P}" STREQUAL "8")
        find_file(OPENNI2_INCLUDES "OpenNI.h" PATHS $ENV{OPENNI2_INCLUDE64} "$ENV{OPEN_NI_INSTALL_PATH64}Include" DOC "OpenNI2 c++ interface header")
        find_library(OPENNI2_LIBRARY "OpenNI2" PATHS $ENV{OPENNI2_LIB64} DOC "OpenNI2 library")
    else()
        find_file(OPENNI2_INCLUDES "OpenNI.h" PATHS "$ENV{OPEN_NI_INSTALL_PATH}Include" DOC "OpenNI2 c++ interface header")
        find_library(OPENNI2_LIBRARY "OpenNI2" PATHS $ENV{OPENNI2_LIB} DOC "OpenNI2 library")
    endif()
elseif(UNIX OR APPLE)
    find_file(OPENNI2_INCLUDES "OpenNI.h" PATHS "/usr/include/ni2" "/usr/include/openni2" $ENV{OPENNI2_INCLUDE} DOC "OpenNI2 c++ interface header")
    find_library(OPENNI2_LIBRARY "OpenNI2" PATHS "/usr/lib" $ENV{OPENNI2_REDIST} DOC "OpenNI2 library")
endif()

get_filename_component(OPENNI2_LIB_DIR "${OPENNI2_LIBRARY}" PATH)
get_filename_component(OPENNI2_INCLUDE_DIR ${OPENNI2_INCLUDES} PATH)



set(OPENNI2_FOUND TRUE)
