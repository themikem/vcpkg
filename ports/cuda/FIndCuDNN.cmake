if(NOT CUDA_FOUND)
    find_package(CUDA REQUIRED)
endif()

include(FindPackageHandleStandardArgs)

get_filename_component(CURRENT_INSTALLED_DIR "../../" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_LIST_DIR}")
message(STATUS "Finding VCPKG CuDNN in ${CURRENT_INSTALLED_DIR}")

set(CUDNN_ROOT "" CACHE PATH "CUDNN root folder")
if(UNIX)
    set(CUDNN_LIB_NAME "libcudnn.so")
elseif(WIN32)
    set(CUDNN_LIB_NAME "cudnn.lib")
endif()

find_path(CUDNN_INCLUDE_DIR cudnn.h
    PATHS ${CUDNN_ROOT} $ENV{CUDNN_ROOT} ${CUDA_TOOLKIT_INCLUDE}
    DOC "Path to cuDNN include directory." )

get_filename_component(__libpath_hist ${CUDA_CUDART_LIBRARY} PATH)
find_library(CUDNN_LIBRARY NAMES ${CUDNN_LIB_NAME}
    PATHS ${CUDNN_ROOT} $ENV{CUDNN_ROOT} ${CUDNN_INCLUDE_DIR} ${__libpath_hist} ${__libpath_hist}/../lib
    DOC "Path to cuDNN library.")

if(CUDNN_INCLUDE_DIR AND CUDNN_LIBRARY)
    file(READ ${CUDNN_INCLUDE_DIR}/cudnn.h CUDNN_VERSION_FILE_CONTENTS)

    # cuDNN v3 and beyond
    string(REGEX MATCH "define CUDNN_MAJOR * +([0-9]+)"
           CUDNN_VERSION_MAJOR "${CUDNN_VERSION_FILE_CONTENTS}")
    string(REGEX REPLACE "define CUDNN_MAJOR * +([0-9]+)" "\\1"
           CUDNN_VERSION_MAJOR "${CUDNN_VERSION_MAJOR}")
    string(REGEX MATCH "define CUDNN_MINOR * +([0-9]+)"
           CUDNN_VERSION_MINOR "${CUDNN_VERSION_FILE_CONTENTS}")
    string(REGEX REPLACE "define CUDNN_MINOR * +([0-9]+)" "\\1"
           CUDNN_VERSION_MINOR "${CUDNN_VERSION_MINOR}")
    string(REGEX MATCH "define CUDNN_PATCHLEVEL * +([0-9]+)"
           CUDNN_VERSION_PATCH "${CUDNN_VERSION_FILE_CONTENTS}")
    string(REGEX REPLACE "define CUDNN_PATCHLEVEL * +([0-9]+)" "\\1"
           CUDNN_VERSION_PATCH "${CUDNN_VERSION_PATCH}")

    if(NOT CUDNN_VERSION_MAJOR)
      set(CUDNN_VERSION "???")
    else()
      set(CUDNN_VERSION "${CUDNN_VERSION_MAJOR}.${CUDNN_VERSION_MINOR}.${CUDNN_VERSION_PATCH}")
    endif()

    message(STATUS "Found cuDNN: ver. ${CUDNN_VERSION} found (include: ${CUDNN_INCLUDE_DIR}, library: ${CUDNN_LIBRARY})")

    string(COMPARE LESS "${CUDNN_VERSION_MAJOR}" 3 cuDNNVersionIncompatible)
    if(cuDNNVersionIncompatible)
      message(FATAL_ERROR "cuDNN version >3 is required.")
    endif()

    set(CUDNN_VERSION "${CUDNN_VERSION}")
endif()

find_package_handle_standard_args(CUDNN DEFAULT_MSG CUDNN_INCLUDE_DIR CUDNN_LIBRARY CUDNN_VERSION)

if(CUDNN_FOUND)
    set(CUDNN_INCLUDE_DIRS ${CUDNN_INCLUDE_DIR})
    set(CUDNN_LIBRARIES ${CUDNN_LIBRARY})
    mark_as_advanced(CUDNN_FOUND CUDNN_INCLUDE_DIRS CUDNN_INCLUDE_DIR CUDNN_LIBRARY CUDNN_LIBRARIES CUDNN_ROOT CUDNN_VERSION)
else(CUDNN_FOUND)
    message(STATUS "cuDNN not found")
endif()