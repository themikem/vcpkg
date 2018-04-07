
# if(HAVE_GSTREAMER)
# IF(WIN32)
#   INCLUDE_DIRECTORIES(${GSTREAMER_INCLUDE_DIR})
#   list(APPEND VIDEOIO_LIBRARIES ${GSTREAMER_LIBRARIES})
# ENDIF(WIN32)
# list(APPEND videoio_srcs ${CMAKE_CURRENT_LIST_DIR}/src/cap_gstreamer.cpp)
# endif(HAVE_GSTREAMER)

# GSTREAMER_gstbase_LIBRARY AND GSTREAMER_gstvideo_LIBRARY AND GSTREAMER_gstapp_LIBRARY AND GSTREAMER_gstpbutils_LIBRARY AND GSTREAMER_gstriff_LIBRARY

# if(WITH_GSTREAMER OR HAVE_GSTREAMER)
#   status("    GStreamer:"      HAVE_GSTREAMER      THEN ""                                         ELSE NO)
#   if(HAVE_GSTREAMER)
#     status("      base:"       "YES (ver ${GSTREAMER_BASE_VERSION})")
#     status("      video:"      "YES (ver ${GSTREAMER_VIDEO_VERSION})")
#     status("      app:"        "YES (ver ${GSTREAMER_APP_VERSION})")
#     status("      riff:"       "YES (ver ${GSTREAMER_RIFF_VERSION})")
#     status("      pbutils:"    "YES (ver ${GSTREAMER_PBUTILS_VERSION})")
#   endif(HAVE_GSTREAMER)
# endif()


set(GSTREAMER_FOUND true)
set(GSTREAMER_ROOT "c:/gstreamer/1.0/x86_64")
set(GSTREAMER_API "1.0")
set(GSTREAMER_VERSION "1.14.0")

set(GSTREAMER_INCLUDE_DIR "${GSTREAMER_ROOT}/include")
set(GSTREAMER_LIBRARIES "")

set(GSTREAMER_LIB_NAMES gstbase gstvideo gstapp gstpbutils gstriff)
foreach(GSTLIB GSTREAMER_LIB_NAMES)
    find_library(GSTREAMER_${GSTLIB}_LIBRARY ${GSTLIB}-${GSTREAMER_API} PATHS GSTREAMER_ROOT PATH_SUFFIXES lib libexec bin DOC "Gstreamer library ${GSTLIB}")
    if(GSTREAMER_${GSTLIB}_LIBRARY)
        list(APPEND GSTREAMER_LIBRARIES ${GSTREAMER_${GSTLIB}_LIBRARY})
    endif()
endforeach(GSTLIB GSTREAMER_LIB_NAMES)

set(GSTREAMER_BASE_VERSION      ${GSTREAMER_API})
set(GSTREAMER_VIDEO_VERSION     ${GSTREAMER_API})
set(GSTREAMER_APP_VERSION       ${GSTREAMER_API})
set(GSTREAMER_RIFF_VERSION      ${GSTREAMER_API})
set(GSTREAMER_PBUTILS_VERSION   ${GSTREAMER_API})

message(STATUS "Found Gstreamer ${GSTREAMER_VERSION} in ${GSTREAMER_ROOT}")