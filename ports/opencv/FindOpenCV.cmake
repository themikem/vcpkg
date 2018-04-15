include(FindPackageHandleStandardArgs)

get_filename_component(CURRENT_INSTALLED_DIR "../../" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_LIST_DIR}")
message(STATUS "Finding VCPKG OpenCV in ${CURRENT_INSTALLED_DIR}")

set(OpenCV_DIR ${CURRENT_INSTALLED_DIR}/share/opencv)

include(${CURRENT_INSTALLED_DIR}/share/opencv/OpenCVConfig.cmake)

find_package_handle_standard_args(OpenCV DEFAULT_MSG OpenCV_LIBS OpenCV_INCLUDE_DIRS OpenCV_VERSION)