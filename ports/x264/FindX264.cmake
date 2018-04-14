get_filename_component(CURRENT_INSTALLED_DIR "../../" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_LIST_DIR}")
message(STATUS "Finding ${VCPKG_LIBRARY_LINKAGE} x624 in ${CURRENT_INSTALLED_DIR}")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    if(CMAKE_BUILD_TYPE MATCHES "Debug")
        set(X264_ROOT "${CURRENT_INSTALLED_DIR}/debug")
    else()
        set(X264_ROOT "${CURRENT_INSTALLED_DIR}")
    endif()
    add_library(x264 SHARED IMPORTED)
else()
    if(CMAKE_BUILD_TYPE MATCHES "Debug")
        set(X264_ROOT "${CURRENT_INSTALLED_DIR}/debug/static")
    else()
        set(X264_ROOT "${CURRENT_INSTALLED_DIR}/static")
    endif()
    add_library(x264 STATIC IMPORTED)
endif()

set(X264_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include")
set(X264_LIBRARY "${X264_ROOT}/lib/libx264.lib")
set(X264_LIBRARIES ${X264_LIBRARY})

set_target_properties(x264 PROPERTIES
  IMPORTED_LOCATION "${X264_LIBRARY}"
  INTERFACE_INCLUDE_DIRECTORIES "${X264_INCLUDE_DIR}"
)

find_package_handle_standard_args(X264 DEFAULT_MSG X264_LIBRARY X264_INCLUDE_DIR)