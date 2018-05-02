include(FindPackageHandleStandardArgs)

get_filename_component(CURRENT_INSTALLED_DIR "../../" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_LIST_DIR}")
message(STATUS "Finding VCPKG Caffe in ${CURRENT_INSTALLED_DIR}")

if(NOT CAFFE_FOUND)
    get_filename_component(CAFFE_BASE_HINT "${CMAKE_CURRENT_LIST_DIR}/../../" ABSOLUTE)
    
    find_path(CAFFE_INCLUDE_DIR
        NAMES 
            caffe/caffe.hpp
            caffe/common.hpp
            caffe/net.hpp
            caffe/proto/caffe.pb.h
            caffe/util/io.hpp 
        HINTS 
            "${CAFFE_BASE_HINT}/include" 
        NO_DEFAULT_PATH)

    if(CMAKE_BUILD_TYPE MATCHES "Debug")
        find_library(CAFFE_LIBRARY
            NAMES 
                caffed
            HINTS
                "${CAFFE_BASE_HINT}/debug/lib"
            NO_DEFAULT_PATH)
    else()
        find_library(CAFFE_LIBRARY
            NAMES 
                caffe
            HINTS
                "${CAFFE_BASE_HINT}/lib"
            NO_DEFAULT_PATH)
    endif()
    
    
    find_package_handle_standard_args(CAFFE DEFAULT_MSG CAFFE_LIBRARY CAFFE_INCLUDE_DIR)
    if(CAFFE_FOUND)
        set(Caffe_FOUND true)
        set(CAFFE_LIBRARIES ${CAFFE_LIBRARY})
        set(Caffe_LIBRARIES ${CAFFE_LIBRARY})
        set(CAFFE_INCLUDE_DIRS ${CAFFE_INCLUDE_DIRS})
        set(Caffe_INCLUDE_DIRS ${CAFFE_INCLUDE_DIRS})
        set(CAFFE_LIBS ${CAFFE_LIBRARY})
        set(Caffe_LIBS ${CAFFE_LIBRARY})
        mark_as_advanced(CAFFE_FOUND CAFFE_LIBRARY CAFFE_INCLUDE_DIR CAFFE_LIBRARIES CAFFE_INCLUDE_DIRS CAFFE_LIBS)
        mark_as_advanced(Caffe_FOUND Caffe_LIBRARY Caffe_INCLUDE_DIR Caffe_LIBRARIES Caffe_INCLUDE_DIRS Caffe_LIBS)

        message(STATUS "Configuring Caffe Targets")

        get_filename_component(OPENCV_DIR "${CMAKE_CURRENT_LIST_DIR}/../opencv" ABSOLUTE)
        get_filename_component(PROTOBUF_DIR "${CMAKE_CURRENT_LIST_DIR}/../protobuf" ABSOLUTE)
        get_filename_component(GFLAGS_DIR "${CMAKE_CURRENT_LIST_DIR}/../protobuf" ABSOLUTE)
        get_filename_component(GLOG_DIR "${CMAKE_CURRENT_LIST_DIR}/../protobuf" ABSOLUTE)
        get_filename_component(HDF5_DIR "${CMAKE_CURRENT_LIST_DIR}/../hdf5" ABSOLUTE)
        get_filename_component(LMDB_DIR "${CMAKE_CURRENT_LIST_DIR}/../lmdb" ABSOLUTE)
        get_filename_component(LEVELDB_DIR "${CMAKE_CURRENT_LIST_DIR}/../leveldb" ABSOLUTE)
        get_filename_component(SNAPPY_DIR "${CMAKE_CURRENT_LIST_DIR}/../snappy" ABSOLUTE)
        get_filename_component(MKL_DIR "${CMAKE_CURRENT_LIST_DIR}/../intel-mkl" ABSOLUTE)
    
        list(APPEND CMAKE_MODULE_PATH ${OPENCV_DIR})
        list(APPEND CMAKE_MODULE_PATH ${PROTOBUF_DIR})
        list(APPEND CMAKE_MODULE_PATH ${GFLAGS_DIR})
        list(APPEND CMAKE_MODULE_PATH ${GLOG_DIR})
        list(APPEND CMAKE_MODULE_PATH ${HDF5_DIR})
        list(APPEND CMAKE_MODULE_PATH ${LMDB_DIR})
        list(APPEND CMAKE_MODULE_PATH ${LEVELDB_DIR})
        list(APPEND CMAKE_MODULE_PATH ${SNAPPY_DIR})
        list(APPEND CMAKE_MODULE_PATH ${MKL_DIR})
    
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
    endif()
endif()
