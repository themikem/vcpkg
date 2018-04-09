message(STATUS "Finding Caffe in ${CMAKE_CURRENT_LIST_DIR}/CaffeConfig.cmake")
if(NOT CAFFE_FOUND)

    include(${CMAKE_CURRENT_LIST_DIR}/CaffeConfig.cmake)
    set(CAFFE_FOUND TRUE)
    set(Caffe_FOUND true)
endif()

message(STATUS "Found Caffe - ${CAFFE_FOUND} - ${Caffe_HAVE_CUDA} / ${Caffe_HAVE_CUDNN} / ${Caffe_LIBRARIES}")
