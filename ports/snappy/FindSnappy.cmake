include(FindPackageHandleStandardArgs)

get_filename_component(CURRENT_INSTALLED_DIR "../../" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_LIST_DIR}")
message(STATUS "Finding VCPKG Snappy in ${CURRENT_INSTALLED_DIR}")

set(SNAPPY_DIR ${CURRENT_INSTALLED_DIR}/share/snappy)

find_path(SNAPPY_INCLUDE_DIR
    NAMES 
        snappy-c.h
        snappy-sinksource.h
        snappy-stubs-public.h
        snappy.h
    HINTS 
        "${CURRENT_INSTALLED_DIR}/include" 
    NO_DEFAULT_PATH)

if(CMAKE_BUILD_TYPE MATCHES "Debug")
    find_library(SNAPPY_LIBRARY
        NAMES 
            snappyd
        HINTS
            "${CURRENT_INSTALLED_DIR}/debug/lib"
        NO_DEFAULT_PATH)
else()
    find_library(SNAPPY_LIBRARY
    NAMES 
        snappy
    HINTS
        "${CURRENT_INSTALLED_DIR}/lib"
    NO_DEFAULT_PATH)
endif()

find_package_handle_standard_args(SNAPPY DEFAULT_MSG SNAPPY_LIBRARY SNAPPY_INCLUDE_DIR)
if(SNAPPY_FOUND)
    set(SNAPPY_LIBRARIES ${SNAPPY_LIBRARY})
    set(SNAPPY_INCLUDE_DIRS ${SNAPPY_INCLUDE_DIRS})
    mark_as_advanced(SNAPPY_FOUND SNAPPY_LIBRARY SNAPPY_INCLUDE_DIR SNAPPY_LIBRARIES SNAPPY_INCLUDE_DIRS)

    message(STATUS "Configuring Snappy Targets")
    include(${CMAKE_CURRENT_LIST_DIR}/SnappyConfig.cmake)
    include(${CMAKE_CURRENT_LIST_DIR}/SnappyConfigVersion.cmake)
    set(SNAPPY_VERSION ${PACKAGE_VERSION})
    set(Snappy_VERSION ${PACKAGE_VERSION})
endif()