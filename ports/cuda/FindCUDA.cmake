# The script defines the following variables::
#
#   CUDA_VERSION_MAJOR    -- The major version of cuda as reported by nvcc.
#   CUDA_VERSION_MINOR    -- The minor version.
#   CUDA_VERSION
#   CUDA_VERSION_STRING   -- CUDA_VERSION_MAJOR.CUDA_VERSION_MINOR
#   CUDA_HAS_FP16         -- Whether a short float (float16,fp16) is supported.
#
#   CUDA_TOOLKIT_ROOT_DIR -- Path to the CUDA Toolkit (defined if not set).
#   CUDA_SDK_ROOT_DIR     -- Path to the CUDA SDK.  Use this to find files in the
#                            SDK.  This script will not directly support finding
#                            specific libraries or headers, as that isn't
#                            supported by NVIDIA.  If you want to change
#                            libraries when the path changes see the
#                            FindCUDA.cmake script for an example of how to clear
#                            these variables.  There are also examples of how to
#                            use the CUDA_SDK_ROOT_DIR to locate headers or
#                            libraries, if you so choose (at your own risk).
#   CUDA_INCLUDE_DIRS     -- Include directory for cuda headers.  Added automatically
#                            for CUDA_ADD_EXECUTABLE and CUDA_ADD_LIBRARY.
#   CUDA_LIBRARIES        -- Cuda RT library.
#   CUDA_CUFFT_LIBRARIES  -- Device or emulation library for the Cuda FFT
#                            implementation (alternative to:
#                            CUDA_ADD_CUFFT_TO_TARGET macro)
#   CUDA_CUBLAS_LIBRARIES -- Device or emulation library for the Cuda BLAS
#                            implementation (alternative to:
#                            CUDA_ADD_CUBLAS_TO_TARGET macro).
#   CUDA_cudart_static_LIBRARY -- Statically linkable cuda runtime library.
#                                 Only available for CUDA version 5.5+
#   CUDA_cudadevrt_LIBRARY -- Device runtime library.
#                             Required for separable compilation.
#   CUDA_cupti_LIBRARY    -- CUDA Profiling Tools Interface library.
#                            Only available for CUDA version 4.0+.
#   CUDA_curand_LIBRARY   -- CUDA Random Number Generation library.
#                            Only available for CUDA version 3.2+.
#   CUDA_cusolver_LIBRARY -- CUDA Direct Solver library.
#                            Only available for CUDA version 7.0+.
#   CUDA_cusparse_LIBRARY -- CUDA Sparse Matrix library.
#                            Only available for CUDA version 3.2+.
#   CUDA_npp_LIBRARY      -- NVIDIA Performance Primitives lib.
#                            Only available for CUDA version 4.0+.
#   CUDA_nppc_LIBRARY     -- NVIDIA Performance Primitives lib (core).
#                            Only available for CUDA version 5.5+.
#   CUDA_nppi_LIBRARY     -- NVIDIA Performance Primitives lib (image processing).
#                            Only available for CUDA version 5.5 - 8.0.
#   CUDA_nppial_LIBRARY   -- NVIDIA Performance Primitives lib (image processing).
#                            Only available for CUDA version 9.0.
#   CUDA_nppicc_LIBRARY   -- NVIDIA Performance Primitives lib (image processing).
#                            Only available for CUDA version 9.0.
#   CUDA_nppicom_LIBRARY  -- NVIDIA Performance Primitives lib (image processing).
#                            Only available for CUDA version 9.0.
#   CUDA_nppidei_LIBRARY  -- NVIDIA Performance Primitives lib (image processing).
#                            Only available for CUDA version 9.0.
#   CUDA_nppif_LIBRARY    -- NVIDIA Performance Primitives lib (image processing).
#                            Only available for CUDA version 9.0.
#   CUDA_nppig_LIBRARY    -- NVIDIA Performance Primitives lib (image processing).
#                            Only available for CUDA version 9.0.
#   CUDA_nppim_LIBRARY    -- NVIDIA Performance Primitives lib (image processing).
#                            Only available for CUDA version 9.0.
#   CUDA_nppist_LIBRARY   -- NVIDIA Performance Primitives lib (image processing).
#                            Only available for CUDA version 9.0.
#   CUDA_nppisu_LIBRARY   -- NVIDIA Performance Primitives lib (image processing).
#                            Only available for CUDA version 9.0.
#   CUDA_nppitc_LIBRARY   -- NVIDIA Performance Primitives lib (image processing).
#                            Only available for CUDA version 9.0.
#   CUDA_npps_LIBRARY     -- NVIDIA Performance Primitives lib (signal processing).
#                            Only available for CUDA version 5.5+.
#   CUDA_nvcuvenc_LIBRARY -- CUDA Video Encoder library.
#                            Only available for CUDA version 3.2+.
#                            Windows only.
#   CUDA_nvcuvid_LIBRARY  -- CUDA Video Decoder library.
#                            Only available for CUDA version 3.2+.
#                            Windows only.
#
set(CUDA_REQUIRED_VERSION "V9.0.0")
set(CMAKE_FIND_LIBRARY_PREFIXES "")
set(CMAKE_FIND_LIBRARY_SUFFIXES ".lib")


# This macro helps us find the location of helper files we will need the full path to
macro(CUDA_FIND_HELPER_FILE _name _extension)
  set(_full_name "${_name}.${_extension}")
  # CMAKE_CURRENT_LIST_FILE contains the full path to the file currently being
  # processed.  Using this variable, we can pull out the current path, and
  # provide a way to get access to the other files we need local to here.
  get_filename_component(CMAKE_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)
  set(CUDA_${_name} "${CMAKE_CURRENT_LIST_DIR}/FindCUDA/${_full_name}")
  if(NOT EXISTS "${CUDA_${_name}}")
    set(error_message "${_full_name} not found in ${CMAKE_CURRENT_LIST_DIR}/FindCUDA")
    if(CUDA_FIND_REQUIRED)
      message(FATAL_ERROR "${error_message}")
    else()
      if(NOT CUDA_FIND_QUIETLY)
        message(STATUS "${error_message}")
      endif()
    endif()
  endif()
  # Set this variable as internal, so the user isn't bugged with it.
  set(CUDA_${_name} ${CUDA_${_name}} CACHE INTERNAL "Location of ${_full_name}" FORCE)
endmacro()

#####################################################################
## CUDA_INCLUDE_NVCC_DEPENDENCIES
##

# So we want to try and include the dependency file if it exists.  If
# it doesn't exist then we need to create an empty one, so we can
# include it.

# If it does exist, then we need to check to see if all the files it
# depends on exist.  If they don't then we should clear the dependency
# file and regenerate it later.  This covers the case where a header
# file has disappeared or moved.

macro(CUDA_INCLUDE_NVCC_DEPENDENCIES dependency_file)
  set(CUDA_NVCC_DEPEND)
  set(CUDA_NVCC_DEPEND_REGENERATE FALSE)


  # Include the dependency file.  Create it first if it doesn't exist .  The
  # INCLUDE puts a dependency that will force CMake to rerun and bring in the
  # new info when it changes.  DO NOT REMOVE THIS (as I did and spent a few
  # hours figuring out why it didn't work.
  if(NOT EXISTS ${dependency_file})
    file(WRITE ${dependency_file} "#FindCUDA.cmake generated file.  Do not edit.\n")
  endif()
  # Always include this file to force CMake to run again next
  # invocation and rebuild the dependencies.
  #message("including dependency_file = ${dependency_file}")
  include(${dependency_file})

  # Now we need to verify the existence of all the included files
  # here.  If they aren't there we need to just blank this variable and
  # make the file regenerate again.
#   if(DEFINED CUDA_NVCC_DEPEND)
#     message("CUDA_NVCC_DEPEND set")
#   else()
#     message("CUDA_NVCC_DEPEND NOT set")
#   endif()
  if(CUDA_NVCC_DEPEND)
    #message("CUDA_NVCC_DEPEND found")
    foreach(f ${CUDA_NVCC_DEPEND})
      # message("searching for ${f}")
      if(NOT EXISTS ${f})
        #message("file ${f} not found")
        set(CUDA_NVCC_DEPEND_REGENERATE TRUE)
      endif()
    endforeach()
  else()
    #message("CUDA_NVCC_DEPEND false")
    # No dependencies, so regenerate the file.
    set(CUDA_NVCC_DEPEND_REGENERATE TRUE)
  endif()

  #message("CUDA_NVCC_DEPEND_REGENERATE = ${CUDA_NVCC_DEPEND_REGENERATE}")
  # No incoming dependencies, so we need to generate them.  Make the
  # output depend on the dependency file itself, which should cause the
  # rule to re-run.
  if(CUDA_NVCC_DEPEND_REGENERATE)
    set(CUDA_NVCC_DEPEND ${dependency_file})
    #message("Generating an empty dependency_file: ${dependency_file}")
    file(WRITE ${dependency_file} "#FindCUDA.cmake generated file.  Do not edit.\n")
  endif()

endmacro()

###############################################################################
###############################################################################
# Setup variables' defaults
###############################################################################
###############################################################################

# Allow the user to specify if the device code is supposed to be 32 or 64 bit.
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
  set(CUDA_64_BIT_DEVICE_CODE_DEFAULT ON)
else()
  set(CUDA_64_BIT_DEVICE_CODE_DEFAULT OFF)
endif()
option(CUDA_64_BIT_DEVICE_CODE "Compile device code in 64 bit mode" ${CUDA_64_BIT_DEVICE_CODE_DEFAULT})

# Attach the build rule to the source file in VS.  This option
option(CUDA_ATTACH_VS_BUILD_RULE_TO_CUDA_FILE "Attach the build rule to the CUDA source file.  Enable only when the CUDA source file is added to at most one target." ON)

# Prints out extra information about the cuda file during compilation
option(CUDA_BUILD_CUBIN "Generate and parse .cubin files in Device mode." OFF)

# Set whether we are using emulation or device mode.
option(CUDA_BUILD_EMULATION "Build in Emulation mode" OFF)

# Where to put the generated output.
set(CUDA_GENERATED_OUTPUT_DIR "" CACHE PATH "Directory to put all the output files.  If blank it will default to the CMAKE_CURRENT_BINARY_DIR")

# Parse HOST_COMPILATION mode.
option(CUDA_HOST_COMPILATION_CPP "Generated file extension" ON)

# Extra user settable flags
# cmake_initialize_per_config_variable(CUDA_NVCC_FLAGS "Semi-colon delimit multiple arguments.")

if(CMAKE_GENERATOR MATCHES "Visual Studio")
  set(_CUDA_MSVC_HOST_COMPILER "$(VCInstallDir)Tools/MSVC/$(VCToolsVersion)/bin/Host$(Platform)/$(PlatformTarget)")
  if(MSVC_VERSION LESS 1910)
   set(_CUDA_MSVC_HOST_COMPILER "$(VCInstallDir)bin")
  endif()

  set(CUDA_HOST_COMPILER "${_CUDA_MSVC_HOST_COMPILER}" CACHE FILEPATH "Host side compiler used by NVCC")

else()
  if(APPLE
      AND "${CMAKE_C_COMPILER_ID}" MATCHES "Clang"
      AND "${CMAKE_C_COMPILER}" MATCHES "/cc$")
    # Using cc which is symlink to clang may let NVCC think it is GCC and issue
    # unhandled -dumpspecs option to clang. Also in case neither
    # CMAKE_C_COMPILER is defined (project does not use C language) nor
    # CUDA_HOST_COMPILER is specified manually we should skip -ccbin and let
    # nvcc use its own default C compiler.
    # Only care about this on APPLE with clang to avoid
    # following symlinks to things like ccache
    if(DEFINED CMAKE_C_COMPILER AND NOT DEFINED CUDA_HOST_COMPILER)
      get_filename_component(c_compiler_realpath "${CMAKE_C_COMPILER}" REALPATH)
      # if the real path does not end up being clang then
      # go back to using CMAKE_C_COMPILER
      if(NOT "${c_compiler_realpath}" MATCHES "/clang$")
        set(c_compiler_realpath "${CMAKE_C_COMPILER}")
      endif()
    else()
      set(c_compiler_realpath "")
    endif()
    set(CUDA_HOST_COMPILER "${c_compiler_realpath}" CACHE FILEPATH "Host side compiler used by NVCC")
  else()
    set(CUDA_HOST_COMPILER "${CMAKE_C_COMPILER}"
      CACHE FILEPATH "Host side compiler used by NVCC")
  endif()
endif()

# Propagate the host flags to the host compiler via -Xcompiler
option(CUDA_PROPAGATE_HOST_FLAGS "Propage C/CXX_FLAGS and friends to the host compiler via -Xcompile" ON)

# Enable CUDA_SEPARABLE_COMPILATION
option(CUDA_SEPARABLE_COMPILATION "Compile CUDA objects with separable compilation enabled.  Requires CUDA 5.0+" OFF)

# Specifies whether the commands used when compiling the .cu file will be printed out.
option(CUDA_VERBOSE_BUILD "Print out the commands run while compiling the CUDA source file.  With the Makefile generator this defaults to VERBOSE variable specified on the command line, but can be forced on with this option." OFF)

mark_as_advanced(
  CUDA_64_BIT_DEVICE_CODE
  CUDA_ATTACH_VS_BUILD_RULE_TO_CUDA_FILE
  CUDA_GENERATED_OUTPUT_DIR
  CUDA_HOST_COMPILATION_CPP
  CUDA_NVCC_FLAGS
  CUDA_PROPAGATE_HOST_FLAGS
  CUDA_BUILD_CUBIN
  CUDA_BUILD_EMULATION
  CUDA_VERBOSE_BUILD
  CUDA_SEPARABLE_COMPILATION
  )

# Single config generators like Makefiles or Ninja don't usually have
# CMAKE_CONFIGURATION_TYPES defined (but note that it can be defined if set by
# projects or developers). Even CMAKE_BUILD_TYPE might not be defined for
# single config generators (and should not be defined for multi-config
# generators). To ensure we get a complete superset of all possible
# configurations, we combine CMAKE_CONFIGURATION_TYPES, CMAKE_BUILD_TYPE and
# all of the standard configurations, then weed out duplicates with
# list(REMOVE_DUPLICATES). Looping over the unique set then ensures we have
# each configuration-specific set of nvcc flags defined and marked as advanced.
set(CUDA_configuration_types ${CMAKE_CONFIGURATION_TYPES} ${CMAKE_BUILD_TYPE} Debug MinSizeRel Release RelWithDebInfo)
list(REMOVE_DUPLICATES CUDA_configuration_types)

###############################################################################
###############################################################################
# Locate CUDA, Set Build Type, etc.
###############################################################################
###############################################################################

macro(cuda_unset_include_and_libraries)
  unset(CUDA_TOOLKIT_INCLUDE CACHE)
  unset(CUDA_CUDART_LIBRARY CACHE)
  unset(CUDA_CUDA_LIBRARY CACHE)
  # Make sure you run this before you unset CUDA_VERSION.
  if(CUDA_VERSION VERSION_EQUAL "3.0")
    # This only existed in the 3.0 version of the CUDA toolkit
    unset(CUDA_CUDARTEMU_LIBRARY CACHE)
  endif()
  unset(CUDA_cudart_static_LIBRARY CACHE)
  unset(CUDA_cudadevrt_LIBRARY CACHE)
  unset(CUDA_cublas_LIBRARY CACHE)
  unset(CUDA_cublas_device_LIBRARY CACHE)
  unset(CUDA_cublasemu_LIBRARY CACHE)
  unset(CUDA_cufft_LIBRARY CACHE)
  unset(CUDA_cufftemu_LIBRARY CACHE)
  unset(CUDA_cupti_LIBRARY CACHE)
  unset(CUDA_curand_LIBRARY CACHE)
  unset(CUDA_cusolver_LIBRARY CACHE)
  unset(CUDA_cusparse_LIBRARY CACHE)
  unset(CUDA_npp_LIBRARY CACHE)
  unset(CUDA_nppc_LIBRARY CACHE)
  unset(CUDA_nppi_LIBRARY CACHE)
  unset(CUDA_npps_LIBRARY CACHE)
  unset(CUDA_nvcuvenc_LIBRARY CACHE)
  unset(CUDA_nvcuvid_LIBRARY CACHE)
  unset(CUDA_GPU_DETECT_OUTPUT CACHE)
endmacro()

# Check to see if the CUDA_TOOLKIT_ROOT_DIR and CUDA_SDK_ROOT_DIR have changed,
# if they have then clear the cache variables, so that will be detected again.
if(NOT "${CUDA_TOOLKIT_ROOT_DIR}" STREQUAL "${CUDA_TOOLKIT_ROOT_DIR_INTERNAL}")
  unset(CUDA_TOOLKIT_TARGET_DIR CACHE)
  unset(CUDA_NVCC_EXECUTABLE CACHE)
  cuda_unset_include_and_libraries()
  unset(CUDA_VERSION CACHE)
endif()

if(NOT "${CUDA_TOOLKIT_TARGET_DIR}" STREQUAL "${CUDA_TOOLKIT_TARGET_DIR_INTERNAL}")
  cuda_unset_include_and_libraries()
endif()

#
#  End of unset()
#

#
#  Start looking for things
#

# Search for the cuda distribution.
if(NOT CUDA_TOOLKIT_ROOT_DIR AND NOT CMAKE_CROSSCOMPILING)
  # Search in the CUDA_BIN_PATH first.
  find_path(CUDA_TOOLKIT_ROOT_DIR
    NAMES nvcc nvcc.exe
    PATHS
      ENV CUDA_TOOLKIT_ROOT
      ENV CUDA_PATH
      ENV CUDA_BIN_PATH
    PATH_SUFFIXES bin bin64
    DOC "Toolkit location."
    NO_DEFAULT_PATH
    )

  # Now search default paths
  find_path(CUDA_TOOLKIT_ROOT_DIR
    NAMES nvcc nvcc.exe
    PATHS /opt/cuda/bin
    PATH_SUFFIXES cuda/bin
    DOC "Toolkit location."
    )

if (CUDA_TOOLKIT_ROOT_DIR)
    string(REGEX REPLACE "[/\\\\]?bin[64]*[/\\\\]?$" "" CUDA_TOOLKIT_ROOT_DIR ${CUDA_TOOLKIT_ROOT_DIR})
    # We need to force this back into the cache.
    set(CUDA_TOOLKIT_ROOT_DIR ${CUDA_TOOLKIT_ROOT_DIR} CACHE PATH "Toolkit location." FORCE)
    set(CUDA_TOOLKIT_TARGET_DIR ${CUDA_TOOLKIT_ROOT_DIR})
  endif()

  if (NOT EXISTS ${CUDA_TOOLKIT_ROOT_DIR})
    if(CUDA_FIND_REQUIRED)
      message(FATAL_ERROR "Specify CUDA_TOOLKIT_ROOT_DIR")
    elseif(NOT CUDA_FIND_QUIETLY)
      message("CUDA_TOOLKIT_ROOT_DIR not found or specified")
    endif()
  endif ()
endif ()

if(CMAKE_CROSSCOMPILING)
  SET (CUDA_TOOLKIT_ROOT $ENV{CUDA_TOOLKIT_ROOT})
  if(CMAKE_SYSTEM_PROCESSOR STREQUAL "armv7-a")
    # Support for NVPACK
    set (CUDA_TOOLKIT_TARGET_NAME "armv7-linux-androideabi")
  elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "arm")
    # Support for arm cross compilation
    set(CUDA_TOOLKIT_TARGET_NAME "armv7-linux-gnueabihf")
  elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64")
    # Support for aarch64 cross compilation
    if (ANDROID_ARCH_NAME STREQUAL "arm64")
      set(CUDA_TOOLKIT_TARGET_NAME "aarch64-linux-androideabi")
    else()
      set(CUDA_TOOLKIT_TARGET_NAME "aarch64-linux")
    endif (ANDROID_ARCH_NAME STREQUAL "arm64")
  endif()

  if (EXISTS "${CUDA_TOOLKIT_ROOT}/targets/${CUDA_TOOLKIT_TARGET_NAME}")
    set(CUDA_TOOLKIT_TARGET_DIR "${CUDA_TOOLKIT_ROOT}/targets/${CUDA_TOOLKIT_TARGET_NAME}" CACHE PATH "CUDA Toolkit target location.")
    SET (CUDA_TOOLKIT_ROOT_DIR ${CUDA_TOOLKIT_ROOT})
    mark_as_advanced(CUDA_TOOLKIT_TARGET_DIR)
  endif()

  # add known CUDA targetr root path to the set of directories we search for programs, libraries and headers
  set( CMAKE_FIND_ROOT_PATH "${CUDA_TOOLKIT_TARGET_DIR};${CMAKE_FIND_ROOT_PATH}")
  macro( cuda_find_host_program )
    if (COMMAND find_host_program)
      find_host_program( ${ARGN} )
    else()
      find_program( ${ARGN} )
    endif()
  endmacro()
else()
  # for non-cross-compile, find_host_program == find_program and CUDA_TOOLKIT_TARGET_DIR == CUDA_TOOLKIT_ROOT_DIR
  macro( cuda_find_host_program )
    find_program( ${ARGN} )
  endmacro()
  SET (CUDA_TOOLKIT_TARGET_DIR ${CUDA_TOOLKIT_ROOT_DIR})
endif()

# CUDA_NVCC_EXECUTABLE
cuda_find_host_program(CUDA_NVCC_EXECUTABLE
  NAMES nvcc
  PATHS "${CUDA_TOOLKIT_ROOT_DIR}"
  ENV CUDA_PATH
  ENV CUDA_BIN_PATH
  PATH_SUFFIXES bin bin64
  NO_DEFAULT_PATH
  )
# Search default search paths, after we search our own set of paths.
cuda_find_host_program(CUDA_NVCC_EXECUTABLE nvcc)
mark_as_advanced(CUDA_NVCC_EXECUTABLE)

if(CUDA_NVCC_EXECUTABLE AND NOT CUDA_VERSION)
  # Compute the version.
  set(error_code 1)
  execute_process (COMMAND ${CUDA_NVCC_EXECUTABLE} "--version" OUTPUT_VARIABLE NVCC_OUT RESULT_VARIABLE error_code)

  if (error_code)
    message(FATAL_ERROR "Could not find CUDA. Before continuing, please download and install CUDA  (${CUDA_REQUIRED_VERSION} or higher) from:"
                        "\n    https://developer.nvidia.com/cuda-downloads\n"
                        "\nAlso ensure vcpkg has been rebuilt with the latest version (v0.0.104 or later)")
  endif()

  string(REGEX REPLACE ".*release ([0-9]+)\\.([0-9]+).*" "\\1" CUDA_VERSION_MAJOR ${NVCC_OUT})
  string(REGEX REPLACE ".*release ([0-9]+)\\.([0-9]+).*" "\\2" CUDA_VERSION_MINOR ${NVCC_OUT})
  set(CUDA_VERSION "${CUDA_VERSION_MAJOR}.${CUDA_VERSION_MINOR}" CACHE STRING "Version of CUDA as computed from nvcc.")
  message(STATUS "Found CUDA ${CUDA_VERSION}")
  mark_as_advanced(CUDA_VERSION)
else()
  # Need to set these based off of the cached value
  string(REGEX REPLACE "([0-9]+)\\.([0-9]+).*" "\\1" CUDA_VERSION_MAJOR "${CUDA_VERSION}")
  string(REGEX REPLACE "([0-9]+)\\.([0-9]+).*" "\\2" CUDA_VERSION_MINOR "${CUDA_VERSION}")
endif()

# Always set this convenience variable
set(CUDA_VERSION_STRING "${CUDA_VERSION}")

if (CUDA_VERSION_MAJOR LESS 9)
    message(FATAL_ERROR "CUDA ${CUDA_VERSION} but ${CUDA_REQUIRED_VERSION} is required. Please download and install a more recent version of CUDA from:"
                        "\n    https://developer.nvidia.com/cuda-downloads\n")
endif()


# CUDA_TOOLKIT_INCLUDE
find_path(CUDA_TOOLKIT_INCLUDE
  device_functions.h # Header included in toolkit
  PATHS ${CUDA_TOOLKIT_TARGET_DIR}
  ENV CUDA_PATH
  ENV CUDA_INC_PATH
  PATH_SUFFIXES include
  NO_DEFAULT_PATH
  )

  # Search default search paths, after we search our own set of paths.
find_path(CUDA_TOOLKIT_INCLUDE device_functions.h)
mark_as_advanced(CUDA_TOOLKIT_INCLUDE)

if (CUDA_VERSION VERSION_GREATER "7.0" OR EXISTS "${CUDA_TOOLKIT_INCLUDE}/cuda_fp16.h")
  set(CUDA_HAS_FP16 TRUE)
else()
  set(CUDA_HAS_FP16 FALSE)
endif()

# Set the user list of include dir to nothing to initialize it.
set (CUDA_NVCC_INCLUDE_DIRS_USER "")
set (CUDA_INCLUDE_DIRS ${CUDA_TOOLKIT_INCLUDE})

# == cuda_find_library_local_first_with_path_ext ===============================
macro(cuda_find_library_local_first_with_path_ext _var _names _doc _path_ext )
  if(VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
    # CUDA 3.2+ on Windows moved the library directories, so we need the new
    # and old paths.
    set(_cuda_64bit_lib_dir "${_path_ext}lib/x64" "${_path_ext}lib64" "${_path_ext}libx64" )
  endif()
  # CUDA 3.2+ on Windows moved the library directories, so we need to new
  # (lib/Win32) and the old path (lib).
  find_library(${_var}
    NAMES ${_names}
    PATHS "${CUDA_TOOLKIT_TARGET_DIR}"
    ENV CUDA_PATH
    ENV CUDA_LIB_PATH
    PATH_SUFFIXES ${_cuda_64bit_lib_dir} "${_path_ext}lib/Win32" "${_path_ext}lib" "${_path_ext}libWin32"
    DOC ${_doc}
    NO_DEFAULT_PATH
    )
  if (NOT CMAKE_CROSSCOMPILING)
    # Search default search paths, after we search our own set of paths.
    find_library(${_var}
      NAMES ${_names}
      PATHS "/usr/lib/nvidia-current"
      DOC ${_doc}
      )
  endif()
endmacro()
# ==============================================================================

# == cuda_find_library_local_first =============================================
macro(cuda_find_library_local_first _var _names _doc)
  cuda_find_library_local_first_with_path_ext( "${_var}" "${_names}" "${_doc}" "" )
endmacro()
# ==============================================================================

# == find_library_local_first ==================================================
macro(find_library_local_first _var _names _doc )
  cuda_find_library_local_first( "${_var}" "${_names}" "${_doc}" "" )
endmacro()
# ==============================================================================

# CUDA_LIBRARIES
cuda_find_library_local_first(CUDA_CUDART_LIBRARY cudart "\"cudart\" library")

if(NOT CUDA_VERSION VERSION_LESS "5.5")
  cuda_find_library_local_first(CUDA_cudart_static_LIBRARY cudart_static "static CUDA runtime library")
  mark_as_advanced(CUDA_cudart_static_LIBRARY)
endif()

if(CUDA_cudart_static_LIBRARY)
  # If static cudart available, use it by default, but provide a user-visible option to disable it.
  option(CUDA_USE_STATIC_CUDA_RUNTIME "Use the static version of the CUDA runtime library if available" ON)
else()
  # If not available, silently disable the option.
  set(CUDA_USE_STATIC_CUDA_RUNTIME OFF CACHE INTERNAL "")
endif()

if(CUDA_USE_STATIC_CUDA_RUNTIME)
  set(CUDA_CUDART_LIBRARY_VAR CUDA_cudart_static_LIBRARY)
else()
  set(CUDA_CUDART_LIBRARY_VAR CUDA_CUDART_LIBRARY)
endif()

if(NOT CUDA_VERSION VERSION_LESS "5.0")
  cuda_find_library_local_first(CUDA_cudadevrt_LIBRARY cudadevrt "\"cudadevrt\" library")
  mark_as_advanced(CUDA_cudadevrt_LIBRARY)
endif()

# CUPTI library showed up in cuda toolkit 4.0
if(NOT CUDA_VERSION VERSION_LESS "4.0")
  cuda_find_library_local_first_with_path_ext(CUDA_cupti_LIBRARY cupti "\"cupti\" library" "extras/CUPTI/")
  mark_as_advanced(CUDA_cupti_LIBRARY)
endif()

# Set the CUDA_LIBRARIES variable.  This is the set of stuff to link against if you are
# using the CUDA runtime.  For the dynamic version of the runtime, most of the
# dependencies are brough in, but for the static version there are additional libraries
# and linker commands needed.
# Initialize to empty
set(CUDA_LIBRARIES)

if(CUDA_USE_STATIC_CUDA_RUNTIME AND CUDA_cudart_static_LIBRARY)
    list(APPEND CUDA_LIBRARIES ${CUDA_cudart_static_LIBRARY} ${CMAKE_THREAD_LIBS_INIT} ${CMAKE_DL_LIBS})
    if (CUDA_rt_LIBRARY)
        list(APPEND CUDA_LIBRARIES ${CUDA_rt_LIBRARY})
    endif()
else()
    list(APPEND CUDA_LIBRARIES ${CUDA_CUDART_LIBRARY})
endif()

get_filename_component(LIB_PATH ${CUDA_CUDART_LIBRARY} DIRECTORY)
set(CUDA_LIBRARY_DIRS ${LIB_PATH})

mark_as_advanced(
  CUDA_CUDA_LIBRARY
  CUDA_CUDART_LIBRARY
  CUDA_LIBRARY_DIRS
  )

# == FIND_CUDA_HELPER_LIBS =====================================================
macro(FIND_CUDA_HELPER_LIBS _name)
    # Look for some of the toolkit helper libraries
    cuda_find_library_local_first(CUDA_${_name}_LIBRARY ${_name} "\"${_name}\" library")
    mark_as_advanced(CUDA_${_name}_LIBRARY)
endmacro()
# ==============================================================================

# Search for additional CUDA toolkit libraries.
find_cuda_helper_libs(cufft)
find_cuda_helper_libs(cublas)
if(NOT CUDA_VERSION VERSION_LESS "3.2")
  # cusparse showed up in version 3.2
  find_cuda_helper_libs(cusparse)
  find_cuda_helper_libs(curand)
  if (WIN32)
    find_cuda_helper_libs(nvcuvenc)
    find_cuda_helper_libs(nvcuvid)
  endif()
endif()
if(CUDA_VERSION VERSION_GREATER "5.0")
  find_cuda_helper_libs(cublas_device)
endif()

if(NOT CUDA_VERSION VERSION_LESS "9.0")
  # In CUDA 9.0 NPP was nppi was removed
  find_cuda_helper_libs(nppc)
  find_cuda_helper_libs(nppial)
  find_cuda_helper_libs(nppicc)
  find_cuda_helper_libs(nppicom)
  find_cuda_helper_libs(nppidei)
  find_cuda_helper_libs(nppif)
  find_cuda_helper_libs(nppig)
  find_cuda_helper_libs(nppim)
  find_cuda_helper_libs(nppist)
  find_cuda_helper_libs(nppisu)
  find_cuda_helper_libs(nppitc)
  find_cuda_helper_libs(npps)
  set(CUDA_npp_LIBRARY "${CUDA_nppc_LIBRARY};${CUDA_nppial_LIBRARY};${CUDA_nppicc_LIBRARY};${CUDA_nppicom_LIBRARY};${CUDA_nppidei_LIBRARY};${CUDA_nppif_LIBRARY};${CUDA_nppig_LIBRARY};${CUDA_nppim_LIBRARY};${CUDA_nppist_LIBRARY};${CUDA_nppisu_LIBRARY};${CUDA_nppitc_LIBRARY};${CUDA_npps_LIBRARY}")
elseif(CUDA_VERSION VERSION_GREATER "5.0")
  # In CUDA 5.5 NPP was split into 3 separate libraries.
  find_cuda_helper_libs(nppc)
  find_cuda_helper_libs(nppi)
  find_cuda_helper_libs(npps)
  set(CUDA_npp_LIBRARY "${CUDA_nppc_LIBRARY};${CUDA_nppi_LIBRARY};${CUDA_npps_LIBRARY}")
elseif(NOT CUDA_VERSION VERSION_LESS "4.0")
  find_cuda_helper_libs(npp)
endif()

if(NOT CUDA_VERSION VERSION_LESS "7.0")
  # cusolver showed up in version 7.0
  find_cuda_helper_libs(cusolver)
endif()

set(CUDA_CUFFT_LIBRARIES ${CUDA_cufft_LIBRARY})
set(CUDA_CUBLAS_LIBRARIES ${CUDA_cublas_LIBRARY} ${CUDA_cublas_device_LIBRARY})

########################
# Look for the SDK stuff.  As of CUDA 3.0 NVSDKCUDA_ROOT has been replaced with
# NVSDKCOMPUTE_ROOT with the old CUDA C contents moved into the C subdirectory
find_path(CUDA_SDK_ROOT_DIR common/inc/cutil.h
 HINTS
  "$ENV{NVSDKCOMPUTE_ROOT}/C"
  ENV NVSDKCUDA_ROOT
  "[HKEY_LOCAL_MACHINE\\SOFTWARE\\NVIDIA Corporation\\Installed Products\\NVIDIA SDK 10\\Compute;InstallDir]"
 PATHS
  "/Developer/GPU\ Computing/C"
  )

# Keep the CUDA_SDK_ROOT_DIR first in order to be able to override the
# environment variables.
set(CUDA_SDK_SEARCH_PATH
  "${CUDA_SDK_ROOT_DIR}"
  "${CUDA_TOOLKIT_ROOT_DIR}/local/NVSDK0.2"
  "${CUDA_TOOLKIT_ROOT_DIR}/NVSDK0.2"
  "${CUDA_TOOLKIT_ROOT_DIR}/NV_CUDA_SDK"
  "$ENV{HOME}/NVIDIA_CUDA_SDK"
  "$ENV{HOME}/NVIDIA_CUDA_SDK_MACOSX"
  "/Developer/CUDA"
  )

#############################
# Check for required components
set(CUDA_FOUND TRUE)

set(CUDA_TOOLKIT_ROOT_DIR_INTERNAL "${CUDA_TOOLKIT_ROOT_DIR}" CACHE INTERNAL
  "This is the value of the last time CUDA_TOOLKIT_ROOT_DIR was set successfully." FORCE)
set(CUDA_TOOLKIT_TARGET_DIR_INTERNAL "${CUDA_TOOLKIT_TARGET_DIR}" CACHE INTERNAL
  "This is the value of the last time CUDA_TOOLKIT_TARGET_DIR was set successfully." FORCE)
set(CUDA_SDK_ROOT_DIR_INTERNAL "${CUDA_SDK_ROOT_DIR}" CACHE INTERNAL
  "This is the value of the last time CUDA_SDK_ROOT_DIR was set successfully." FORCE)

include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(CUDA
  REQUIRED_VARS
    CUDA_TOOLKIT_ROOT_DIR
    CUDA_NVCC_EXECUTABLE
    CUDA_INCLUDE_DIRS
    ${CUDA_CUDART_LIBRARY_VAR}
  VERSION_VAR
    CUDA_VERSION
  )



###############################################################################
###############################################################################
# Macros
###############################################################################
###############################################################################

###############################################################################
# Add include directories to pass to the nvcc command.
macro(CUDA_INCLUDE_DIRECTORIES)
foreach(dir ${ARGN})
  list(APPEND CUDA_NVCC_INCLUDE_DIRS_USER ${dir})
endforeach()
endmacro()


##############################################################################
cuda_find_helper_file(parse_cubin cmake)
cuda_find_helper_file(make2cmake cmake)
cuda_find_helper_file(run_nvcc cmake)
include("${CMAKE_CURRENT_LIST_DIR}/FindCUDA/select_compute_arch.cmake")

##############################################################################
# Separate the OPTIONS out from the sources
#
macro(CUDA_GET_SOURCES_AND_OPTIONS _sources _cmake_options _options)
set( ${_sources} )
set( ${_cmake_options} )
set( ${_options} )
set( _found_options FALSE )
foreach(arg ${ARGN})
  if("x${arg}" STREQUAL "xOPTIONS")
    set( _found_options TRUE )
  elseif(
      "x${arg}" STREQUAL "xWIN32" OR
      "x${arg}" STREQUAL "xMACOSX_BUNDLE" OR
      "x${arg}" STREQUAL "xEXCLUDE_FROM_ALL" OR
      "x${arg}" STREQUAL "xSTATIC" OR
      "x${arg}" STREQUAL "xSHARED" OR
      "x${arg}" STREQUAL "xMODULE"
      )
    list(APPEND ${_cmake_options} ${arg})
  else()
    if ( _found_options )
      list(APPEND ${_options} ${arg})
    else()
      # Assume this is a file
      list(APPEND ${_sources} ${arg})
    endif()
  endif()
endforeach()
endmacro()

##############################################################################
# Parse the OPTIONS from ARGN and set the variables prefixed by _option_prefix
#
macro(CUDA_PARSE_NVCC_OPTIONS _option_prefix)
set( _found_config )
foreach(arg ${ARGN})
  # Determine if we are dealing with a perconfiguration flag
  foreach(config ${CUDA_configuration_types})
    string(TOUPPER ${config} config_upper)
    if (arg STREQUAL "${config_upper}")
      set( _found_config _${arg})
      # Set arg to nothing to keep it from being processed further
      set( arg )
    endif()
  endforeach()

  if ( arg )
    list(APPEND ${_option_prefix}${_found_config} "${arg}")
  endif()
endforeach()
endmacro()

##############################################################################
# Helper to add the include directory for CUDA only once
function(CUDA_ADD_CUDA_INCLUDE_ONCE)
get_directory_property(_include_directories INCLUDE_DIRECTORIES)
set(_add TRUE)
if(_include_directories)
  foreach(dir ${_include_directories})
    if("${dir}" STREQUAL "${CUDA_INCLUDE_DIRS}")
      set(_add FALSE)
    endif()
  endforeach()
endif()
if(_add)
  include_directories(${CUDA_INCLUDE_DIRS})
endif()
endfunction()

function(CUDA_BUILD_SHARED_LIBRARY shared_flag)
set(cmake_args ${ARGN})
# If SHARED, MODULE, or STATIC aren't already in the list of arguments, then
# add SHARED or STATIC based on the value of BUILD_SHARED_LIBS.
list(FIND cmake_args SHARED _cuda_found_SHARED)
list(FIND cmake_args MODULE _cuda_found_MODULE)
list(FIND cmake_args STATIC _cuda_found_STATIC)
if( _cuda_found_SHARED GREATER -1 OR
    _cuda_found_MODULE GREATER -1 OR
    _cuda_found_STATIC GREATER -1)
  set(_cuda_build_shared_libs)
else()
  if (BUILD_SHARED_LIBS)
    set(_cuda_build_shared_libs SHARED)
  else()
    set(_cuda_build_shared_libs STATIC)
  endif()
endif()
set(${shared_flag} ${_cuda_build_shared_libs} PARENT_SCOPE)
endfunction()

##############################################################################
# Helper to avoid clashes of files with the same basename but different paths.
# This doesn't attempt to do exactly what CMake internals do, which is to only
# add this path when there is a conflict, since by the time a second collision
# in names is detected it's already too late to fix the first one.  For
# consistency sake the relative path will be added to all files.
function(CUDA_COMPUTE_BUILD_PATH path build_path)
#message("CUDA_COMPUTE_BUILD_PATH([${path}] ${build_path})")
# Only deal with CMake style paths from here on out
file(TO_CMAKE_PATH "${path}" bpath)
if (IS_ABSOLUTE "${bpath}")
  # Absolute paths are generally unnessary, especially if something like
  # file(GLOB_RECURSE) is used to pick up the files.

  string(FIND "${bpath}" "${CMAKE_CURRENT_BINARY_DIR}" _binary_dir_pos)
  if (_binary_dir_pos EQUAL 0)
    file(RELATIVE_PATH bpath "${CMAKE_CURRENT_BINARY_DIR}" "${bpath}")
  else()
    file(RELATIVE_PATH bpath "${CMAKE_CURRENT_SOURCE_DIR}" "${bpath}")
  endif()
endif()

# This recipe is from cmLocalGenerator::CreateSafeUniqueObjectFileName in the
# CMake source.

# Remove leading /
string(REGEX REPLACE "^[/]+" "" bpath "${bpath}")
# Avoid absolute paths by removing ':'
string(REPLACE ":" "_" bpath "${bpath}")
# Avoid relative paths that go up the tree
string(REPLACE "../" "__/" bpath "${bpath}")
# Avoid spaces
string(REPLACE " " "_" bpath "${bpath}")

# Strip off the filename.  I wait until here to do it, since removin the
# basename can make a path that looked like path/../basename turn into
# path/.. (notice the trailing slash).
get_filename_component(bpath "${bpath}" PATH)

set(${build_path} "${bpath}" PARENT_SCOPE)
#message("${build_path} = ${bpath}")
endfunction()

##############################################################################
# This helper macro populates the following variables and setups up custom
# commands and targets to invoke the nvcc compiler to generate C or PTX source
# dependent upon the format parameter.  The compiler is invoked once with -M
# to generate a dependency file and a second time with -cuda or -ptx to generate
# a .cpp or .ptx file.
# INPUT:
#   cuda_target         - Target name
#   format              - PTX, CUBIN, FATBIN or OBJ
#   FILE1 .. FILEN      - The remaining arguments are the sources to be wrapped.
#   OPTIONS             - Extra options to NVCC
# OUTPUT:
#   generated_files     - List of generated files
##############################################################################
##############################################################################

macro(CUDA_WRAP_SRCS cuda_target format generated_files)

# Put optional arguments in list.
set(_argn_list "${ARGN}")
# If one of the given optional arguments is "PHONY", make a note of it, then
# remove it from the list.
list(FIND _argn_list "PHONY" _phony_idx)
if("${_phony_idx}" GREATER "-1")
  set(_target_is_phony true)
  list(REMOVE_AT _argn_list ${_phony_idx})
else()
  set(_target_is_phony false)
endif()

# If CMake doesn't support separable compilation, complain
if(CUDA_SEPARABLE_COMPILATION AND CMAKE_VERSION VERSION_LESS "2.8.10.1")
  message(SEND_ERROR "CUDA_SEPARABLE_COMPILATION isn't supported for CMake versions less than 2.8.10.1")
endif()

# Set up all the command line flags here, so that they can be overridden on a per target basis.

set(nvcc_flags "")

# Emulation if the card isn't present.
if (CUDA_BUILD_EMULATION)
  # Emulation.
  set(nvcc_flags ${nvcc_flags} --device-emulation -D_DEVICEEMU -g)
else()
  # Device mode.  No flags necessary.
endif()

if(CUDA_HOST_COMPILATION_CPP)
  set(CUDA_C_OR_CXX CXX)
else()
  if(CUDA_VERSION VERSION_LESS "3.0")
    set(nvcc_flags ${nvcc_flags} --host-compilation C)
  else()
    message(WARNING "--host-compilation flag is deprecated in CUDA version >= 3.0.  Removing --host-compilation C flag" )
  endif()
  set(CUDA_C_OR_CXX C)
endif()

set(generated_extension ${CMAKE_${CUDA_C_OR_CXX}_OUTPUT_EXTENSION})

if(CUDA_64_BIT_DEVICE_CODE)
  set(nvcc_flags ${nvcc_flags} -m64)
else()
  set(nvcc_flags ${nvcc_flags} -m32)
endif()

if(CUDA_TARGET_CPU_ARCH)
  set(nvcc_flags ${nvcc_flags} "--target-cpu-architecture=${CUDA_TARGET_CPU_ARCH}")
endif()

# This needs to be passed in at this stage, because VS needs to fill out the
# various macros from within VS.  Note that CCBIN is only used if
# -ccbin or --compiler-bindir isn't used and CUDA_HOST_COMPILER matches
# _CUDA_MSVC_HOST_COMPILER
if(CMAKE_GENERATOR MATCHES "Visual Studio")
  set(ccbin_flags -D "\"CCBIN:PATH=${_CUDA_MSVC_HOST_COMPILER}\"" )
else()
  set(ccbin_flags)
endif()

# Figure out which configure we will use and pass that in as an argument to
# the script.  We need to defer the decision until compilation time, because
# for VS projects we won't know if we are making a debug or release build
# until build time.
if(CMAKE_GENERATOR MATCHES "Visual Studio")
  set( CUDA_build_configuration "$(ConfigurationName)" )
else()
  set( CUDA_build_configuration "${CMAKE_BUILD_TYPE}")
endif()

# Initialize our list of includes with the user ones followed by the CUDA system ones.
set(CUDA_NVCC_INCLUDE_DIRS ${CUDA_NVCC_INCLUDE_DIRS_USER} "${CUDA_INCLUDE_DIRS}")
if(_target_is_phony)
  # If the passed in target name isn't a real target (i.e., this is from a call to one of the
  # cuda_compile_* functions), need to query directory properties to get include directories
  # and compile definitions.
  get_directory_property(_dir_include_dirs INCLUDE_DIRECTORIES)
  get_directory_property(_dir_compile_defs COMPILE_DEFINITIONS)

  list(APPEND CUDA_NVCC_INCLUDE_DIRS "${_dir_include_dirs}")
  set(CUDA_NVCC_COMPILE_DEFINITIONS "${_dir_compile_defs}")
else()
  # Append the include directories for this target via generator expression, which is
  # expanded by the FILE(GENERATE) call below.  This generator expression captures all
  # include dirs set by the user, whether via directory properties or target properties
  list(APPEND CUDA_NVCC_INCLUDE_DIRS "$<TARGET_PROPERTY:${cuda_target},INCLUDE_DIRECTORIES>")

  # Do the same thing with compile definitions
  set(CUDA_NVCC_COMPILE_DEFINITIONS "$<TARGET_PROPERTY:${cuda_target},COMPILE_DEFINITIONS>")
endif()


# Reset these variables
set(CUDA_WRAP_OPTION_NVCC_FLAGS)
foreach(config ${CUDA_configuration_types})
  string(TOUPPER ${config} config_upper)
  set(CUDA_WRAP_OPTION_NVCC_FLAGS_${config_upper})
endforeach()

CUDA_GET_SOURCES_AND_OPTIONS(_cuda_wrap_sources _cuda_wrap_cmake_options _cuda_wrap_options ${_argn_list})
CUDA_PARSE_NVCC_OPTIONS(CUDA_WRAP_OPTION_NVCC_FLAGS ${_cuda_wrap_options})

# Figure out if we are building a shared library.  BUILD_SHARED_LIBS is
# respected in CUDA_ADD_LIBRARY.
set(_cuda_build_shared_libs FALSE)
# SHARED, MODULE
list(FIND _cuda_wrap_cmake_options SHARED _cuda_found_SHARED)
list(FIND _cuda_wrap_cmake_options MODULE _cuda_found_MODULE)
if(_cuda_found_SHARED GREATER -1 OR _cuda_found_MODULE GREATER -1)
  set(_cuda_build_shared_libs TRUE)
endif()
# STATIC
list(FIND _cuda_wrap_cmake_options STATIC _cuda_found_STATIC)
if(_cuda_found_STATIC GREATER -1)
  set(_cuda_build_shared_libs FALSE)
endif()

# CUDA_HOST_FLAGS
if(_cuda_build_shared_libs)
  # If we are setting up code for a shared library, then we need to add extra flags for
  # compiling objects for shared libraries.
  set(CUDA_HOST_SHARED_FLAGS ${CMAKE_SHARED_LIBRARY_${CUDA_C_OR_CXX}_FLAGS})
else()
  set(CUDA_HOST_SHARED_FLAGS)
endif()
# Only add the CMAKE_{C,CXX}_FLAGS if we are propagating host flags.  We
# always need to set the SHARED_FLAGS, though.
if(CUDA_PROPAGATE_HOST_FLAGS)
  set(_cuda_host_flags "set(CMAKE_HOST_FLAGS ${CMAKE_${CUDA_C_OR_CXX}_FLAGS} ${CUDA_HOST_SHARED_FLAGS})")
else()
  set(_cuda_host_flags "set(CMAKE_HOST_FLAGS ${CUDA_HOST_SHARED_FLAGS})")
endif()

set(_cuda_nvcc_flags_config "# Build specific configuration flags")
# Loop over all the configuration types to generate appropriate flags for run_nvcc.cmake
foreach(config ${CUDA_configuration_types})
  string(TOUPPER ${config} config_upper)
  # CMAKE_FLAGS are strings and not lists.  By not putting quotes around CMAKE_FLAGS
  # we convert the strings to lists (like we want).

  if(CUDA_PROPAGATE_HOST_FLAGS)
    # nvcc chokes on -g3 in versions previous to 3.0, so replace it with -g
    set(_cuda_fix_g3 FALSE)

    if(CMAKE_COMPILER_IS_GNUCC)
      if (CUDA_VERSION VERSION_LESS  "3.0" OR
          CUDA_VERSION VERSION_EQUAL "4.1" OR
          CUDA_VERSION VERSION_EQUAL "4.2"
          )
        set(_cuda_fix_g3 TRUE)
      endif()
    endif()
    if(_cuda_fix_g3)
      string(REPLACE "-g3" "-g" _cuda_C_FLAGS "${CMAKE_${CUDA_C_OR_CXX}_FLAGS_${config_upper}}")
    else()
      set(_cuda_C_FLAGS "${CMAKE_${CUDA_C_OR_CXX}_FLAGS_${config_upper}}")
    endif()

    string(APPEND _cuda_host_flags "\nset(CMAKE_HOST_FLAGS_${config_upper} ${_cuda_C_FLAGS})")
  endif()

  # Note that if we ever want CUDA_NVCC_FLAGS_<CONFIG> to be string (instead of a list
  # like it is currently), we can remove the quotes around the
  # ${CUDA_NVCC_FLAGS_${config_upper}} variable like the CMAKE_HOST_FLAGS_<CONFIG> variable.
  string(APPEND _cuda_nvcc_flags_config "\nset(CUDA_NVCC_FLAGS_${config_upper} ${CUDA_NVCC_FLAGS_${config_upper}} ;; ${CUDA_WRAP_OPTION_NVCC_FLAGS_${config_upper}})")
endforeach()

# Process the C++11 flag.  If the host sets the flag, we need to add it to nvcc and
# remove it from the host. This is because -Xcompile -std=c++ will choke nvcc (it uses
# the C preprocessor).  In order to get this to work correctly, we need to use nvcc's
# specific c++11 flag.
if( "${_cuda_host_flags}" MATCHES "-std=c\\+\\+11")
  # Add the c++11 flag to nvcc if it isn't already present.  Note that we only look at
  # the main flag instead of the configuration specific flags.
  if( NOT "${CUDA_NVCC_FLAGS}" MATCHES "-std=c\\+\\+11" )
    list(APPEND nvcc_flags --std c++11)
  endif()
  string(REGEX REPLACE "[-]+std=c\\+\\+11" "" _cuda_host_flags "${_cuda_host_flags}")
endif()

if(_cuda_build_shared_libs)
  list(APPEND nvcc_flags "-D${cuda_target}_EXPORTS")
endif()

# Reset the output variable
set(_cuda_wrap_generated_files "")

# Iterate over the macro arguments and create custom
# commands for all the .cu files.
foreach(file ${_argn_list})
  # Ignore any file marked as a HEADER_FILE_ONLY
  get_source_file_property(_is_header ${file} HEADER_FILE_ONLY)
  # Allow per source file overrides of the format.  Also allows compiling non-.cu files.
  get_source_file_property(_cuda_source_format ${file} CUDA_SOURCE_PROPERTY_FORMAT)
  if((${file} MATCHES "\\.cu$" OR _cuda_source_format) AND NOT _is_header)

    if(NOT _cuda_source_format)
      set(_cuda_source_format ${format})
    endif()
    # If file isn't a .cu file, we need to tell nvcc to treat it as such.
    if(NOT ${file} MATCHES "\\.cu$")
      set(cuda_language_flag -x=cu)
    else()
      set(cuda_language_flag)
    endif()

    if( ${_cuda_source_format} MATCHES "OBJ")
      set( cuda_compile_to_external_module OFF )
    else()
      set( cuda_compile_to_external_module ON )
      if( ${_cuda_source_format} MATCHES "PTX" )
        set( cuda_compile_to_external_module_type "ptx" )
      elseif( ${_cuda_source_format} MATCHES "CUBIN")
        set( cuda_compile_to_external_module_type "cubin" )
      elseif( ${_cuda_source_format} MATCHES "FATBIN")
        set( cuda_compile_to_external_module_type "fatbin" )
      else()
        message( FATAL_ERROR "Invalid format flag passed to CUDA_WRAP_SRCS or set with CUDA_SOURCE_PROPERTY_FORMAT file property for file '${file}': '${_cuda_source_format}'.  Use OBJ, PTX, CUBIN or FATBIN.")
      endif()
    endif()

    if(cuda_compile_to_external_module)
      # Don't use any of the host compilation flags for PTX targets.
      set(CUDA_HOST_FLAGS)
      set(CUDA_NVCC_FLAGS_CONFIG)
    else()
      set(CUDA_HOST_FLAGS ${_cuda_host_flags})
      set(CUDA_NVCC_FLAGS_CONFIG ${_cuda_nvcc_flags_config})
    endif()

    # Determine output directory
    cuda_compute_build_path("${file}" cuda_build_path)
    set(cuda_compile_intermediate_directory "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${cuda_target}.dir/${cuda_build_path}")
    if(CUDA_GENERATED_OUTPUT_DIR)
      set(cuda_compile_output_dir "${CUDA_GENERATED_OUTPUT_DIR}")
    else()
      if ( cuda_compile_to_external_module )
        set(cuda_compile_output_dir "${CMAKE_CURRENT_BINARY_DIR}")
      else()
        set(cuda_compile_output_dir "${cuda_compile_intermediate_directory}")
      endif()
    endif()

    # Add a custom target to generate a c or ptx file. ######################

    get_filename_component( basename ${file} NAME )
    if( cuda_compile_to_external_module )
      set(generated_file_path "${cuda_compile_output_dir}")
      set(generated_file_basename "${cuda_target}_generated_${basename}.${cuda_compile_to_external_module_type}")
      set(format_flag "-${cuda_compile_to_external_module_type}")
      file(MAKE_DIRECTORY "${cuda_compile_output_dir}")
    else()
      set(generated_file_path "${cuda_compile_output_dir}/${CMAKE_CFG_INTDIR}")
      set(generated_file_basename "${cuda_target}_generated_${basename}${generated_extension}")
      if(CUDA_SEPARABLE_COMPILATION)
        set(format_flag "-dc")
      else()
        set(format_flag "-c")
      endif()
    endif()

    # Set all of our file names.  Make sure that whatever filenames that have
    # generated_file_path in them get passed in through as a command line
    # argument, so that the ${CMAKE_CFG_INTDIR} gets expanded at run time
    # instead of configure time.
    set(generated_file "${generated_file_path}/${generated_file_basename}")
    set(cmake_dependency_file "${cuda_compile_intermediate_directory}/${generated_file_basename}.depend")
    set(NVCC_generated_dependency_file "${cuda_compile_intermediate_directory}/${generated_file_basename}.NVCC-depend")
    set(generated_cubin_file "${generated_file_path}/${generated_file_basename}.cubin.txt")
    set(custom_target_script_pregen "${cuda_compile_intermediate_directory}/${generated_file_basename}.cmake.pre-gen")
    set(custom_target_script "${cuda_compile_intermediate_directory}/${generated_file_basename}$<$<BOOL:$<CONFIG>>:.$<CONFIG>>.cmake")

    # Setup properties for obj files:
    if( NOT cuda_compile_to_external_module )
      set_source_files_properties("${generated_file}"
        PROPERTIES
        EXTERNAL_OBJECT true # This is an object file not to be compiled, but only be linked.
        )
    endif()

    # Don't add CMAKE_CURRENT_SOURCE_DIR if the path is already an absolute path.
    get_filename_component(file_path "${file}" PATH)
    if(IS_ABSOLUTE "${file_path}")
      set(source_file "${file}")
    else()
      set(source_file "${CMAKE_CURRENT_SOURCE_DIR}/${file}")
    endif()

    if( NOT cuda_compile_to_external_module AND CUDA_SEPARABLE_COMPILATION)
      list(APPEND ${cuda_target}_SEPARABLE_COMPILATION_OBJECTS "${generated_file}")
    endif()

    # Bring in the dependencies.  Creates a variable CUDA_NVCC_DEPEND #######
    cuda_include_nvcc_dependencies(${cmake_dependency_file})

    # Convience string for output ###########################################
    if(CUDA_BUILD_EMULATION)
      set(cuda_build_type "Emulation")
    else()
      set(cuda_build_type "Device")
    endif()

    # Build the NVCC made dependency file ###################################
    set(build_cubin OFF)
    if ( NOT CUDA_BUILD_EMULATION AND CUDA_BUILD_CUBIN )
       if ( NOT cuda_compile_to_external_module )
         set ( build_cubin ON )
       endif()
    endif()

    # Configure the build script
    configure_file("${CUDA_run_nvcc}" "${custom_target_script_pregen}" @ONLY)
    file(GENERATE
      OUTPUT "${custom_target_script}"
      INPUT "${custom_target_script_pregen}"
      )

    # So if a user specifies the same cuda file as input more than once, you
    # can have bad things happen with dependencies.  Here we check an option
    # to see if this is the behavior they want.
    if(CUDA_ATTACH_VS_BUILD_RULE_TO_CUDA_FILE)
      set(main_dep MAIN_DEPENDENCY ${source_file})
    else()
      set(main_dep DEPENDS ${source_file})
    endif()

    if(CUDA_VERBOSE_BUILD)
      set(verbose_output ON)
    elseif(CMAKE_GENERATOR MATCHES "Makefiles")
      set(verbose_output "$(VERBOSE)")
    else()
      set(verbose_output OFF)
    endif()

    # Create up the comment string
    file(RELATIVE_PATH generated_file_relative_path "${CMAKE_BINARY_DIR}" "${generated_file}")
    if(cuda_compile_to_external_module)
      set(cuda_build_comment_string "Building NVCC ${cuda_compile_to_external_module_type} file ${generated_file_relative_path}")
    else()
      set(cuda_build_comment_string "Building NVCC (${cuda_build_type}) object ${generated_file_relative_path}")
    endif()

    set(_verbatim VERBATIM)
    if(ccbin_flags MATCHES "\\$\\(VCInstallDir\\)")
      set(_verbatim "")
    endif()

    # Build the generated file and dependency file ##########################
    add_custom_command(
      OUTPUT ${generated_file}
      # These output files depend on the source_file and the contents of cmake_dependency_file
      ${main_dep}
      DEPENDS ${CUDA_NVCC_DEPEND}
      DEPENDS ${custom_target_script}
      # Make sure the output directory exists before trying to write to it.
      COMMAND ${CMAKE_COMMAND} -E make_directory "${generated_file_path}"
      COMMAND ${CMAKE_COMMAND} ARGS
        -D verbose:BOOL=${verbose_output}
        ${ccbin_flags}
        -D build_configuration:STRING=${CUDA_build_configuration}
        -D "generated_file:STRING=${generated_file}"
        -D "generated_cubin_file:STRING=${generated_cubin_file}"
        -P "${custom_target_script}"
      WORKING_DIRECTORY "${cuda_compile_intermediate_directory}"
      COMMENT "${cuda_build_comment_string}"
      ${_verbatim}
      )

    # Make sure the build system knows the file is generated.
    set_source_files_properties(${generated_file} PROPERTIES GENERATED TRUE)

    list(APPEND _cuda_wrap_generated_files ${generated_file})

    # Add the other files that we want cmake to clean on a cleanup ##########
    list(APPEND CUDA_ADDITIONAL_CLEAN_FILES "${cmake_dependency_file}")
    list(REMOVE_DUPLICATES CUDA_ADDITIONAL_CLEAN_FILES)
    set(CUDA_ADDITIONAL_CLEAN_FILES ${CUDA_ADDITIONAL_CLEAN_FILES} CACHE INTERNAL "List of intermediate files that are part of the cuda dependency scanning.")

  endif()
endforeach()

# Set the return parameter
set(${generated_files} ${_cuda_wrap_generated_files})
endmacro()

function(_cuda_get_important_host_flags important_flags flag_string)
if(CMAKE_GENERATOR MATCHES "Visual Studio")
  string(REGEX MATCHALL "/M[DT][d]?" flags "${flag_string}")
  list(APPEND ${important_flags} ${flags})
else()
  string(REGEX MATCHALL "-fPIC" flags "${flag_string}")
  list(APPEND ${important_flags} ${flags})
endif()
set(${important_flags} ${${important_flags}} PARENT_SCOPE)
endfunction()

###############################################################################
###############################################################################
# Separable Compilation Link
###############################################################################
###############################################################################

# Compute the filename to be used by CUDA_LINK_SEPARABLE_COMPILATION_OBJECTS
function(CUDA_COMPUTE_SEPARABLE_COMPILATION_OBJECT_FILE_NAME output_file_var cuda_target object_files)
if (object_files)
  set(generated_extension ${CMAKE_${CUDA_C_OR_CXX}_OUTPUT_EXTENSION})
  set(output_file "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${cuda_target}.dir/${CMAKE_CFG_INTDIR}/${cuda_target}_intermediate_link${generated_extension}")
else()
  set(output_file)
endif()

set(${output_file_var} "${output_file}" PARENT_SCOPE)
endfunction()

# Setup the build rule for the separable compilation intermediate link file.
function(CUDA_LINK_SEPARABLE_COMPILATION_OBJECTS output_file cuda_target options object_files)
if (object_files)

  set_source_files_properties("${output_file}"
    PROPERTIES
    EXTERNAL_OBJECT TRUE # This is an object file not to be compiled, but only
                         # be linked.
    GENERATED TRUE       # This file is generated during the build
    )

  # For now we are ignoring all the configuration specific flags.
  set(nvcc_flags)
  CUDA_PARSE_NVCC_OPTIONS(nvcc_flags ${options})
  if(CUDA_64_BIT_DEVICE_CODE)
    list(APPEND nvcc_flags -m64)
  else()
    list(APPEND nvcc_flags -m32)
  endif()
  # If -ccbin, --compiler-bindir has been specified, don't do anything.  Otherwise add it here.
  list( FIND nvcc_flags "-ccbin" ccbin_found0 )
  list( FIND nvcc_flags "--compiler-bindir" ccbin_found1 )
  if( ccbin_found0 LESS 0 AND ccbin_found1 LESS 0 AND CUDA_HOST_COMPILER )
    # Match VERBATIM check below.
    if(CUDA_HOST_COMPILER MATCHES "\\$\\(VCInstallDir\\)")
      list(APPEND nvcc_flags -ccbin "\"${CUDA_HOST_COMPILER}\"")
    else()
      list(APPEND nvcc_flags -ccbin "${CUDA_HOST_COMPILER}")
    endif()
  endif()

  # Create a list of flags specified by CUDA_NVCC_FLAGS_${CONFIG} and CMAKE_${CUDA_C_OR_CXX}_FLAGS*
  set(config_specific_flags)
  set(flags)
  foreach(config ${CUDA_configuration_types})
    string(TOUPPER ${config} config_upper)
    # Add config specific flags
    foreach(f ${CUDA_NVCC_FLAGS_${config_upper}})
      list(APPEND config_specific_flags $<$<CONFIG:${config}>:${f}>)
    endforeach()
    set(important_host_flags)
    _cuda_get_important_host_flags(important_host_flags "${CMAKE_${CUDA_C_OR_CXX}_FLAGS_${config_upper}}")
    foreach(f ${important_host_flags})
      list(APPEND flags $<$<CONFIG:${config}>:-Xcompiler> $<$<CONFIG:${config}>:${f}>)
    endforeach()
  endforeach()
  # Add CMAKE_${CUDA_C_OR_CXX}_FLAGS
  set(important_host_flags)
  _cuda_get_important_host_flags(important_host_flags "${CMAKE_${CUDA_C_OR_CXX}_FLAGS}")
  foreach(f ${important_host_flags})
    list(APPEND flags -Xcompiler ${f})
  endforeach()

  # Add our general CUDA_NVCC_FLAGS with the configuration specifig flags
  set(nvcc_flags ${CUDA_NVCC_FLAGS} ${config_specific_flags} ${nvcc_flags})

  file(RELATIVE_PATH output_file_relative_path "${CMAKE_BINARY_DIR}" "${output_file}")

  # Some generators don't handle the multiple levels of custom command
  # dependencies correctly (obj1 depends on file1, obj2 depends on obj1), so
  # we work around that issue by compiling the intermediate link object as a
  # pre-link custom command in that situation.
  set(do_obj_build_rule TRUE)
  if (MSVC_VERSION GREATER 1599 AND MSVC_VERSION LESS 1800)
    # VS 2010 and 2012 have this problem.
    set(do_obj_build_rule FALSE)
  endif()

  set(_verbatim VERBATIM)
  if(nvcc_flags MATCHES "\\$\\(VCInstallDir\\)")
    set(_verbatim "")
  endif()

  if (do_obj_build_rule)
    add_custom_command(
      OUTPUT ${output_file}
      DEPENDS ${object_files}
      COMMAND ${CUDA_NVCC_EXECUTABLE} ${nvcc_flags} -dlink ${object_files} ${CUDA_cublas_device_LIBRARY} -o ${output_file}
      ${flags}
      COMMENT "Building NVCC intermediate link file ${output_file_relative_path}"
      COMMAND_EXPAND_LISTS
      ${_verbatim}
      )
  else()
    get_filename_component(output_file_dir "${output_file}" DIRECTORY)
    add_custom_command(
      TARGET ${cuda_target}
      PRE_LINK
      COMMAND ${CMAKE_COMMAND} -E echo "Building NVCC intermediate link file ${output_file_relative_path}"
      COMMAND ${CMAKE_COMMAND} -E make_directory "${output_file_dir}"
      COMMAND ${CUDA_NVCC_EXECUTABLE} ${nvcc_flags} ${flags} -dlink ${object_files} ${CUDA_cublas_device_LIBRARY} -o "${output_file}"
      COMMAND_EXPAND_LISTS
      ${_verbatim}
      )
  endif()
endif()
endfunction()

###############################################################################
###############################################################################
# ADD LIBRARY
###############################################################################
###############################################################################
macro(CUDA_ADD_LIBRARY cuda_target)

CUDA_ADD_CUDA_INCLUDE_ONCE()

# Separate the sources from the options
CUDA_GET_SOURCES_AND_OPTIONS(_sources _cmake_options _options ${ARGN})
CUDA_BUILD_SHARED_LIBRARY(_cuda_shared_flag ${ARGN})
# Create custom commands and targets for each file.
CUDA_WRAP_SRCS( ${cuda_target} OBJ _generated_files ${_sources}
  ${_cmake_options} ${_cuda_shared_flag}
  OPTIONS ${_options} )

# Compute the file name of the intermedate link file used for separable
# compilation.
CUDA_COMPUTE_SEPARABLE_COMPILATION_OBJECT_FILE_NAME(link_file ${cuda_target} "${${cuda_target}_SEPARABLE_COMPILATION_OBJECTS}")

# Add the library.
add_library(${cuda_target} ${_cmake_options}
  ${_generated_files}
  ${_sources}
  ${link_file}
  )

# Add a link phase for the separable compilation if it has been enabled.  If
# it has been enabled then the ${cuda_target}_SEPARABLE_COMPILATION_OBJECTS
# variable will have been defined.
CUDA_LINK_SEPARABLE_COMPILATION_OBJECTS("${link_file}" ${cuda_target} "${_options}" "${${cuda_target}_SEPARABLE_COMPILATION_OBJECTS}")

target_link_libraries(${cuda_target} ${CUDA_LINK_LIBRARIES_KEYWORD}
  ${CUDA_LIBRARIES}
  )

if(CUDA_SEPARABLE_COMPILATION)
  target_link_libraries(${cuda_target} ${CUDA_LINK_LIBRARIES_KEYWORD}
    ${CUDA_cudadevrt_LIBRARY}
    )
endif()

# We need to set the linker language based on what the expected generated file
# would be. CUDA_C_OR_CXX is computed based on CUDA_HOST_COMPILATION_CPP.
set_target_properties(${cuda_target}
  PROPERTIES
  LINKER_LANGUAGE ${CUDA_C_OR_CXX}
  )

endmacro()


###############################################################################
###############################################################################
# ADD EXECUTABLE
###############################################################################
###############################################################################
macro(CUDA_ADD_EXECUTABLE cuda_target)

CUDA_ADD_CUDA_INCLUDE_ONCE()

# Separate the sources from the options
CUDA_GET_SOURCES_AND_OPTIONS(_sources _cmake_options _options ${ARGN})
# Create custom commands and targets for each file.
CUDA_WRAP_SRCS( ${cuda_target} OBJ _generated_files ${_sources} OPTIONS ${_options} )

# Compute the file name of the intermedate link file used for separable
# compilation.
CUDA_COMPUTE_SEPARABLE_COMPILATION_OBJECT_FILE_NAME(link_file ${cuda_target} "${${cuda_target}_SEPARABLE_COMPILATION_OBJECTS}")

# Add the library.
add_executable(${cuda_target} ${_cmake_options}
  ${_generated_files}
  ${_sources}
  ${link_file}
  )

# Add a link phase for the separable compilation if it has been enabled.  If
# it has been enabled then the ${cuda_target}_SEPARABLE_COMPILATION_OBJECTS
# variable will have been defined.
CUDA_LINK_SEPARABLE_COMPILATION_OBJECTS("${link_file}" ${cuda_target} "${_options}" "${${cuda_target}_SEPARABLE_COMPILATION_OBJECTS}")

target_link_libraries(${cuda_target} ${CUDA_LINK_LIBRARIES_KEYWORD}
  ${CUDA_LIBRARIES}
  )

# We need to set the linker language based on what the expected generated file
# would be. CUDA_C_OR_CXX is computed based on CUDA_HOST_COMPILATION_CPP.
set_target_properties(${cuda_target}
  PROPERTIES
  LINKER_LANGUAGE ${CUDA_C_OR_CXX}
  )

endmacro()


###############################################################################
###############################################################################
# (Internal) helper for manually added cuda source files with specific targets
###############################################################################
###############################################################################
macro(cuda_compile_base cuda_target format generated_files)
# Update a counter in this directory, to keep phony target names unique.
set(_cuda_target "${cuda_target}")
get_property(_counter DIRECTORY PROPERTY _cuda_internal_phony_counter)
if(_counter)
  math(EXPR _counter "${_counter} + 1")
else()
  set(_counter 1)
endif()
string(APPEND _cuda_target "_${_counter}")
set_property(DIRECTORY PROPERTY _cuda_internal_phony_counter ${_counter})

# Separate the sources from the options
CUDA_GET_SOURCES_AND_OPTIONS(_sources _cmake_options _options ${ARGN})

# Create custom commands and targets for each file.
CUDA_WRAP_SRCS( ${_cuda_target} ${format} _generated_files ${_sources}
                ${_cmake_options} OPTIONS ${_options} PHONY)

set( ${generated_files} ${_generated_files})

endmacro()

###############################################################################
###############################################################################
# CUDA COMPILE
###############################################################################
###############################################################################
macro(CUDA_COMPILE generated_files)
cuda_compile_base(cuda_compile OBJ ${generated_files} ${ARGN})
endmacro()

###############################################################################
###############################################################################
# CUDA COMPILE PTX
###############################################################################
###############################################################################
macro(CUDA_COMPILE_PTX generated_files)
cuda_compile_base(cuda_compile_ptx PTX ${generated_files} ${ARGN})
endmacro()

###############################################################################
###############################################################################
# CUDA COMPILE FATBIN
###############################################################################
###############################################################################
macro(CUDA_COMPILE_FATBIN generated_files)
cuda_compile_base(cuda_compile_fatbin FATBIN ${generated_files} ${ARGN})
endmacro()

###############################################################################
###############################################################################
# CUDA COMPILE CUBIN
###############################################################################
###############################################################################
macro(CUDA_COMPILE_CUBIN generated_files)
cuda_compile_base(cuda_compile_cubin CUBIN ${generated_files} ${ARGN})
endmacro()


###############################################################################
###############################################################################
# CUDA ADD CUFFT TO TARGET
###############################################################################
###############################################################################
macro(CUDA_ADD_CUFFT_TO_TARGET target)
if (CUDA_BUILD_EMULATION)
  target_link_libraries(${target} ${CUDA_LINK_LIBRARIES_KEYWORD} ${CUDA_cufftemu_LIBRARY})
else()
  target_link_libraries(${target} ${CUDA_LINK_LIBRARIES_KEYWORD} ${CUDA_cufft_LIBRARY})
endif()
endmacro()

###############################################################################
###############################################################################
# CUDA ADD CUBLAS TO TARGET
###############################################################################
###############################################################################
macro(CUDA_ADD_CUBLAS_TO_TARGET target)
if (CUDA_BUILD_EMULATION)
  target_link_libraries(${target} ${CUDA_LINK_LIBRARIES_KEYWORD} ${CUDA_cublasemu_LIBRARY})
else()
  target_link_libraries(${target} ${CUDA_LINK_LIBRARIES_KEYWORD} ${CUDA_cublas_LIBRARY} ${CUDA_cublas_device_LIBRARY})
endif()
endmacro()

###############################################################################
###############################################################################
# CUDA BUILD CLEAN TARGET
###############################################################################
###############################################################################
macro(CUDA_BUILD_CLEAN_TARGET)
# Call this after you add all your CUDA targets, and you will get a convience
# target.  You should also make clean after running this target to get the
# build system to generate all the code again.

set(cuda_clean_target_name clean_cuda_depends)
if (CMAKE_GENERATOR MATCHES "Visual Studio")
  string(TOUPPER ${cuda_clean_target_name} cuda_clean_target_name)
endif()
add_custom_target(${cuda_clean_target_name}
  COMMAND ${CMAKE_COMMAND} -E remove ${CUDA_ADDITIONAL_CLEAN_FILES})

# Clear out the variable, so the next time we configure it will be empty.
# This is useful so that the files won't persist in the list after targets
# have been removed.
set(CUDA_ADDITIONAL_CLEAN_FILES "" CACHE INTERNAL "List of intermediate files that are part of the cuda dependency scanning.")
endmacro()