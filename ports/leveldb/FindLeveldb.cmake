include(FindPackageHandleStandardArgs)

get_filename_component(CURRENT_INSTALLED_DIR "../../" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_LIST_DIR}")
message(STATUS "Finding VCPKG LevelDB in ${CURRENT_INSTALLED_DIR}")

set(LEVELDB_DIR ${CURRENT_INSTALLED_DIR}/share/leveldb)

find_path(LEVELDB_INCLUDE_DIR
    NAMES
        leveldb/db.h
    HINTS 
        "${CURRENT_INSTALLED_DIR}/include" 
    NO_DEFAULT_PATH
)

if(CMAKE_BUILD_TYPE MATCHES "Debug")
    find_library(LEVELDB_LIBRARY
        NAMES
            leveldb
        HINTS
            "${CURRENT_INSTALLED_DIR}/lib"
        NO_DEFAULT_PATH
    )
else()
    find_library(LEVELDB_LIBRARY
        NAMES
            leveldb
        HINTS
            "${CURRENT_INSTALLED_DIR}/debug/lib"
        NO_DEFAULT_PATH
    )
endif()

find_package_handle_standard_args(LEVELDB DEFAULT_MSG LEVELDB_LIBRARY LEVELDB_INCLUDE_DIR)
if(LEVELDB_FOUND)
    set(LEVELDB_LIBRARIES ${LEVELDB_LIBRARY})
    set(LevelDB_LIBRARIES ${LEVELDB_LIBRARY})
    set(LEVELDB_INCLUDE_DIRS ${LEVELDB_INCLUDE_DIRS})
    set(LevelDB_INCLUDE_DIRS ${LEVELDB_INCLUDE_DIRS})
    set(LevelDB_INCLUDES ${LEVELDB_INCLUDE_DIRS})
    mark_as_advanced(LEVELDB_FOUND LEVELDB_LIBRARY LEVELDB_INCLUDE_DIR LEVELDB_LIBRARIES LEVELDB_INCLUDE_DIRS)

    message(STATUS "Configuring LevelDB Targets")
    include(${CMAKE_CURRENT_LIST_DIR}/LeveldbConfig.cmake)
    include(${CMAKE_CURRENT_LIST_DIR}/LeveldbConfigVersion.cmake)
    set(LEVELDB_VERSION ${PACKAGE_VERSION})
    set(LevelDB_VERSION ${PACKAGE_VERSION})
endif()