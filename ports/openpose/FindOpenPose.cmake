include(FindPackageHandleStandardArgs)

get_filename_component(CURRENT_INSTALLED_DIR "../../" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_LIST_DIR}")
message(STATUS "Finding VCPKG OpenPose in ${CURRENT_INSTALLED_DIR}")

set(OPENPOSE_DIR ${CURRENT_INSTALLED_DIR}/share/snappy)

find_path(OPENPOSE_INCLUDE_DIR
    NAMES 
        headers.hpp
        core/headers.hpp
    HINTS 
        "${CURRENT_INSTALLED_DIR}/include/openpose" 
    NO_DEFAULT_PATH)

if(CMAKE_BUILD_TYPE MATCHES "Debug")
    find_library(OPENPOSE_LIBRARY
        NAMES 
            openpose
        HINTS
            "${CURRENT_INSTALLED_DIR}/debug/lib"
        NO_DEFAULT_PATH)
else()
    find_library(OPENPOSE_LIBRARY
        NAMES 
            openpose
        HINTS
            "${CURRENT_INSTALLED_DIR}/lib"
        NO_DEFAULT_PATH)
endif()

find_package_handle_standard_args(OPENPOSE DEFAULT_MSG OPENPOSE_LIBRARY OPENPOSE_INCLUDE_DIR)
if(OPENPOSE_FOUND)
    set(OPENPOSE_LIBRARIES ${OPENPOSE_LIBRARY})
    set(OPENPOSE_INCLUDE_DIRS ${OPENPOSE_INCLUDE_DIRS})
    mark_as_advanced(OPENPOSE_FOUND OPENPOSE_LIBRARY OPENPOSE_INCLUDE_DIR OPENPOSE_LIBRARIES OPENPOSE_INCLUDE_DIRS)

    message(STATUS "Configuring OpenPose Targets")
    include(${CMAKE_CURRENT_LIST_DIR}/OpenPoseConfig.cmake)
endif()