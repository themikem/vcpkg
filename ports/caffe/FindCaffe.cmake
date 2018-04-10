message(STATUS "Finding Caffe in ${CMAKE_CURRENT_LIST_DIR}/CaffeConfig.cmake")
if(NOT CAFFE_FOUND)
    get_filename_component(PROTOBUF_FIND_PATH "${CMAKE_CURRENT_LIST_DIR}/../protobuf" ABSOLUTE)
    get_filename_component(HDF5_FIND_PATH "${CMAKE_CURRENT_LIST_DIR}/../hdf5" ABSOLUTE)
    get_filename_component(MKL_FIND_PATH "${CMAKE_CURRENT_LIST_DIR}/../intel-mkl" ABSOLUTE)

    list(INSERT CMAKE_MODULES_PATH 0 ${MKL_FIND_PATH})
    list(INSERT CMAKE_MODULES_PATH 0 ${HDF5_FIND_PATH})
    list(INSERT CMAKE_MODULES_PATH 0 ${PROTOBUF_FIND_PATH})

    find_package(protobuf)
    find_package(HDF5)
    find_package(MKL)

    include(${CMAKE_CURRENT_LIST_DIR}/CaffeConfig.cmake)
    set(CAFFE_FOUND TRUE)
    set(Caffe_FOUND true)
endif()

message(STATUS "Found Caffe - ${CAFFE_FOUND} - ${Caffe_HAVE_CUDA} / ${Caffe_HAVE_CUDNN} / ${Caffe_LIBRARIES}")
