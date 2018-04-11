message(STATUS "Finding Caffe in ${CMAKE_CURRENT_LIST_DIR}/CaffeConfig.cmake")
if(NOT CAFFE_FOUND)
    get_filename_component(OPENCV_DIR "${CMAKE_CURRENT_LIST_DIR}/../opencv" ABSOLUTE)
    get_filename_component(PROTOBUF_DIR "${CMAKE_CURRENT_LIST_DIR}/../protobuf" ABSOLUTE)
    get_filename_component(GFLAGS_DIR "${CMAKE_CURRENT_LIST_DIR}/../protobuf" ABSOLUTE)
    get_filename_component(GLOG_DIR "${CMAKE_CURRENT_LIST_DIR}/../protobuf" ABSOLUTE)
    get_filename_component(HDF5_DIR "${CMAKE_CURRENT_LIST_DIR}/../hdf5" ABSOLUTE)
    get_filename_component(LMDB_DIR "${CMAKE_CURRENT_LIST_DIR}/../lmdb" ABSOLUTE)
    get_filename_component(LEVELDB_DIR "${CMAKE_CURRENT_LIST_DIR}/../leveldb" ABSOLUTE)
    get_filename_component(SNAPPY_DIR "${CMAKE_CURRENT_LIST_DIR}/../snappy" ABSOLUTE)
    get_filename_component(MKL_DIR "${CMAKE_CURRENT_LIST_DIR}/../intel-mkl" ABSOLUTE)

    list(INSERT CMAKE_MODULES_PATH 0 ${OPENCV_DIR})
    list(INSERT CMAKE_MODULES_PATH 0 ${PROTOBUF_DIR})
    list(INSERT CMAKE_MODULES_PATH 0 ${GFLAGS_DIR})
    list(INSERT CMAKE_MODULES_PATH 0 ${GLOG_DIR})
    list(INSERT CMAKE_MODULES_PATH 0 ${HDF5_DIR})
    list(INSERT CMAKE_MODULES_PATH 0 ${LMDB_DIR})
    list(INSERT CMAKE_MODULES_PATH 0 ${LEVELDB_DIR})
    list(INSERT CMAKE_MODULES_PATH 0 ${SNAPPY_DIR})
    list(INSERT CMAKE_MODULES_PATH 0 ${MKL_DIR})

    find_package(opencv)
    find_package(protobuf)
    find_package(gflags)
    find_package(glog)
    find_package(HDF5)
    find_package(LMDB)
    find_package(LEVELDB)
    find_package(SNAPPY)
    find_package(MKL)

    include(${CMAKE_CURRENT_LIST_DIR}/CaffeConfig.cmake)
    set(CAFFE_FOUND TRUE)
    set(Caffe_FOUND true)

    get_filename_component(Caffe_BASE_HINT "${CMAKE_CURRENT_LIST_DIR}/../../" ABSOLUTE)
    
    find_path(Caffe_INCLUDE_DIRS 
        NAMES 
            caffe/caffe.hpp
            caffe/common.hpp
            caffe/net.hpp
            caffe/proto/caffe.pb.h
            caffe/util/io.hpp 
        HINTS 
            "${Caffe_BASE_HINT}/include" 
        NO_DEFAULT_PATH)

    find_library(Caffe_LIBS 
        NAMES 
            caffe
        HINTS
            "${Caffe_BASE_HINT}/lib"
        NO_DEFAULT_PATH)
endif()

message(STATUS "Found Caffe - ${CAFFE_FOUND} - (Include: ${Caffe_INCLUDE_DIRS} / Libs: ${Caffe_LIBS} ) - CUDA: ${Caffe_HAVE_CUDA} / CUDNN: ${Caffe_HAVE_CUDNN} / ${Caffe_LIBRARIES}")
