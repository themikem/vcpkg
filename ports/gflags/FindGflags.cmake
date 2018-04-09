message(STATUS "Finding Gflags in ${CMAKE_CURRENT_LIST_DIR}/gflags-config.cmake")
if(NOT GFLAGS_FOUND)
    include(${CMAKE_CURRENT_LIST_DIR}/gflags-config.cmake)

    include(FindPackageHandleStandardArgs)

    if(MSVC)
        find_library(GFLAGS_LIBRARY_RELEASE
            NAMES gflags
            PATHS ${CMAKE_CURRENT_LIST_DIR}/../../lib
            PATH_SUFFIXES Release)

        find_library(GFLAGS_LIBRARY_DEBUG
            NAMES gflagsd
            PATHS ${CMAKE_CURRENT_LIST_DIR}/../../debug/lib
            PATH_SUFFIXES Debug)

        set(GFLAGS_LIBRARY optimized ${GFLAGS_LIBRARY_RELEASE} debug ${GFLAGS_LIBRARY_DEBUG})
    else()
        find_library(GFLAGS_LIBRARY gflags)
    endif()

    find_package_handle_standard_args(GFlags DEFAULT_MSG GFLAGS_INCLUDE_DIR GFLAGS_LIBRARY)

    if(GFLAGS_FOUND)
        set(GFLAGS_INCLUDE_DIRS ${GFLAGS_INCLUDE_DIR})
        set(GFLAGS_LIBRARIES ${GFLAGS_LIBRARY})
        message(STATUS "Found gflags  (include: ${GFLAGS_INCLUDE_DIR}, library: ${GFLAGS_LIBRARY})")
        mark_as_advanced(GFLAGS_FOUND GFLAGS_LIBRARY_DEBUG GFLAGS_LIBRARY_RELEASE GFLAGS_INCLUDE_DIRS GFLAGS_LIBRARIES
                        GFLAGS_LIBRARY GFLAGS_INCLUDE_DIR GFLAGS_ROOT_DIR)
    endif()
else()
    message(STATUS "Loading GFLAGS from cache (include: ${GFLAGS_INCLUDE_DIR}, library: ${GFLAGS_LIBRARY})")
endif()