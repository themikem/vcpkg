message(STATUS "Finding Glog in ${CMAKE_CURRENT_LIST_DIR}/glog-config.cmake")
if(NOT GLOG_FOUND)
    include(${CMAKE_CURRENT_LIST_DIR}/glog-config.cmake)

    include(FindPackageHandleStandardArgs)

    set(GLOG_ROOT_DIR "" CACHE PATH "Folder contains Google glog")

    find_path(GLOG_INCLUDE_DIR glog/logging.h PATHS ${CMAKE_CURRENT_LIST_DIR}/include)

    if(MSVC)
        find_library(GLOG_LIBRARY_RELEASE glog
            PATHS ${CMAKE_CURRENT_LIST_DIR}/../../lib
            PATH_SUFFIXES Release)

        find_library(GLOG_LIBRARY_DEBUG glog
            PATHS ${CMAKE_CURRENT_LIST_DIR}/../../debug/lib
            PATH_SUFFIXES Debug)

        set(GLOG_LIBRARY optimized ${GLOG_LIBRARY_RELEASE} debug ${GLOG_LIBRARY_DEBUG})
    else()
        find_library(GLOG_LIBRARY glog
            PATHS ${GLOG_ROOT_DIR}
            PATH_SUFFIXES lib lib64)
    endif()

    find_package_handle_standard_args(Glog DEFAULT_MSG GLOG_INCLUDE_DIR GLOG_LIBRARY)

    if(GLOG_FOUND)
    set(GLOG_INCLUDE_DIRS ${GLOG_INCLUDE_DIR})
    set(GLOG_LIBRARIES ${GLOG_LIBRARY})
    message(STATUS "Found glog    (include: ${GLOG_INCLUDE_DIR}, library: ${GLOG_LIBRARY})")
    mark_as_advanced(GLOG_ROOT_DIR GLOG_LIBRARY_RELEASE GLOG_LIBRARY_DEBUG
                                    GLOG_LIBRARY GLOG_INCLUDE_DIR GLOG_INCLUDE_DIRS GLOG_LIBRARIES)
    endif()
else()
    message(STATUS "Found glog from cache (include: ${GLOG_INCLUDE_DIR}, library: ${GLOG_LIBRARY})")
endif()