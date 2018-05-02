get_filename_component(CURRENT_INSTALLED_DIR "../../" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_LIST_DIR}")
message(STATUS "Finding VCPKG Protobuf in ${CURRENT_INSTALLED_DIR}")

set(Protobuf_DIR ${CURRENT_INSTALLED_DIR}/share/protobuf)

set(protobuf_MODULE_COMPATIBLE TRUE)
include(${CURRENT_INSTALLED_DIR}/share/protobuf/protobuf-config.cmake)