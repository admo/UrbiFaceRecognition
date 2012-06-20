# FindUrbi.cmake - Tries to find Urbi SDK 2.x
# Copyright (C) 2006-2010, Gostai S.A.S.
#
# This software is provided "as is" without warranty of any kind,
# either expressed or implied, including but not limited to the
# implied warranties of fitness for a particular purpose.
#
# See the LICENSE file for more information.
#
#
# Search strategy of this module:
# 1. Use URBI_ROOT environment variable.
# 2. Use the URBI_ROOT_DIR variable set in cmake.
# 3. Use classical strategy of the find_xxx cmake commands.
#
# Debugging:
#
# You can set URBI_DEBUG to TRUE to enable debugging output of FindUrbi.cmake
# if you are having problems. Please enable this before filing any bug reports.
#
# This module sets those variables:
#
# URBI_FOUND                    System has Urbi, this means the include
#                               directory was found, as well as all the
#                               required libraries.
#
# URBI_INCLUDE_DIRS             Urbi include directories: not cached
#
# URBI_INCLUDE_DIR              This is almost the same as above, but this one
#                               is cached.
#
# URBI_LIBRARIES                Link to these to use the Urbi libraries: not
#                               cached.
#
# URBI_LIBRARY_DIRS             The path where the UrbiSDK library files are.
#
# URBI_EXECUTABLE               Path to the Urbi binary.
#
# URBI_EXECUTABLE_DIR           Directory where to find Urbi executables.
#
# URBI_VERSION_STRING           The version string of Urbi has reported by the
#                               Urbi binary.
#
# URBI_VERSION_MAJOR            The major version number extracted from the
#                               version string.
#
# URBI_VERSION_MINOR            The minor version number extracted from the
#                               version string.
#
# URBI_VERSION_PATCH            The patch version number extracted from the
#                               version string.
#
# URBI_VERSION_RC               The release candidate number extracted from the
#                               version string if any. 0 otherwise.
#
# URBI_VERSION_REV              The revision number extracted from the version
#                               string.
#

#FIXME: Handle required version number.

# ========================== #
# Build searched directories #
# ========================== #

set(URBI_ROOT_ARCHIS
mingw32
i686-pc-linux-gnu
)

set(DETECTED_URBI_ROOT_ARCHI mingw32)

if(UNIX)
  set(DETECTED_URBI_ROOT_ARCHI i686-pc-linux-gnu)
endif()

set(URBI_ROOT_ARCHI ${DETECTED_URBI_ROOT_ARCHI}
  CACHE STRING "May be one of these: ${URBI_ROOT_ARCHIS}")

message(STATUS "URBI_ROOT_ARCHI '${URBI_ROOT_ARCHI}'")

if(URBI_ROOT_DIR)
  list(APPEND _urbi_INCLUDE_SEARCH_DIR ${URBI_ROOT_DIR}/include)
  list(APPEND _urbi_LIBRARY_SEARCH_DIR
    ${URBI_ROOT_DIR}/bin
    ${URBI_ROOT_DIR}/gostai/core/${URBI_ROOT_ARCHI}/engine
    ${URBI_ROOT_DIR}/gostai/engine
    ${URBI_ROOT_DIR}/lib
    ${URBI_ROOT_DIR}/lib/gostai
    ${URBI_ROOT_DIR}/lib/gostai/engine
    ${URBI_ROOT_DIR}/lib/gostai/uobjects
    ${URBI_ROOT_DIR}/lib/gostai/uobjects/urbi
    )
  list(APPEND _urbi_EXECUTABLE_SEARCH_DIR ${URBI_ROOT}/bin)
endif()

if(NOT $ENV{URBI_ROOT} STREQUAL "")
  file(TO_CMAKE_PATH $ENV{URBI_ROOT} _urbi_ENV_ROOT)
  list(APPEND _urbi_INCLUDE_SEARCH_DIR ${_urbi_ENV_ROOT}/include)
  list(APPEND _urbi_LIBRARY_SEARCH_DIR
    ${_urbi_ENV_ROOT}/bin
    ${_urbi_ENV_ROOT}/lib/gostai/engine
    ${_urbi_ENV_ROOT}/bin/gostai/engine
    ${_urbi_ENV_ROOT}/gostai/core/${URBI_ROOT_ARCHI}/engine
    ${_urbi_ENV_ROOT}/lib
    )
  list(APPEND _urbi_EXECUTABLE_SEARCH_DIR ${_urbi_ENV_ROOT}/bin)
endif()

message(STATUS "_urbi_INCLUDE_SEARCH_DIR ${_urbi_INCLUDE_SEARCH_DIR}")
message(STATUS "_urbi_LIBRARY_SEARCH_DIR ${_urbi_LIBRARY_SEARCH_DIR}")
message(STATUS "_urbi_EXECUTABLE_SEARCH_DIR ${_urbi_EXECUTABLE_SEARCH_DIR}")


# =================== #
# Include directories #
# =================== #

find_path(URBI_INCLUDE_DIR
  NAMES urbi/uobject.hh
  HINTS ${_urbi_INCLUDE_SEARCH_DIR}
  DOC "Path to the Urbi SDK include directory")

list(APPEND URBI_INCLUDE_DIRS ${URBI_INCLUDE_DIR})

message(STATUS "URBI_INCLUDE_DIRS ${URBI_INCLUDE_DIRS}")

# ========= #
# Libraries #
# ========= #

find_library(URBI_LIBRARY
  NAMES urbi liburbi liburbi-vc80 liburbi-vc90 liburbi-vc80-d liburbi-vc90-d
  HINTS ${_urbi_LIBRARY_SEARCH_DIR}
  DOC "Path to the Urbi library.")
message(STATUS "URBI_LIBRARY ${URBI_LIBRARY}")

find_library(URBI_UOBJECT_LIBRARY
  NAMES uobject libuobject libuobject-vc80 libuobject-vc90 libuobject-vc80-d
        libuobject-vc90-d
  HINTS ${_urbi_LIBRARY_SEARCH_DIR}
  DOC "Path to the UObject library.")
message(STATUS "URBI_UOBJECT_LIBRARY ${URBI_UOBJECT_LIBRARY}")

find_library(URBI_JPEG_LIBRARY
  NAMES jpeg jpeg4urbi libjpeg libjpeg4urbi libjpeg-vc90 libjpeg4urbi-vc90 libjpeg-vc90-d libjpeg4urbi-vc90-d
  HINTS ${_urbi_LIBRARY_SEARCH_DIR}
  DOC "Path to the JPEG library ship with Urbi.")
message(STATUS "URBI_JPEG_LIBRARY ${URBI_JPEG_LIBRARY}")

find_library(URBI_PORT_LIBRARY
  NAMES port libport libport-vc80 libport-vc90 libport-vc80-d libport-vc90-d
  HINTS ${_urbi_LIBRARY_SEARCH_DIR}
  DOC "Path to the Portable library ship with Urbi.")
message(STATUS "URBI_PORT_LIBRARY ${URBI_PORT_LIBRARY}")
get_filename_component(URBI_PORT_LIBRARY_DIR "${URBI_PORT_LIBRARY}" PATH)

find_library(URBI_SCHED_LIBRARY
  NAMES sched libsched libsched-vc80 libsched-vc90 libsched-vc80-d
        libsched-vc90-d
  HINTS ${_urbi_LIBRARY_SEARCH_DIR}
  DOC "Path to the Scheduler library ship with Urbi.")
message(STATUS "URBI_SCHED_LIBRARY ${URBI_SCHED_LIBRARY}")

list(APPEND URBI_LIBRARIES
  ${URBI_LIBRARY}
  ${URBI_UOBJECT_LIBRARY}
  ${URBI_JPEG_LIBRARY}
  ${URBI_PORT_LIBRARY}
  ${URBI_SCHED_LIBRARY}
  )

foreach(_urbi_lib ${URBI_LIBRARIES})
  get_filename_component(_urbi_lib_path "${_urbi_lib}" PATH)
  list(APPEND URBI_LIBRARY_DIRS ${_urbi_lib_path})
endforeach(_urbi_lib)

# =========== #
# Executables #
# =========== #

find_program(URBI_EXECUTABLE
  NAMES urbi
  HINTS ${_urbi_EXECUTABLE_SEARCH_DIR}
  DOC "Path to the Urbi executable.")
get_filename_component(URBI_EXECUTABLE_DIR "${URBI_EXECUTABLE}" PATH)
message(STATUS "URBI_EXECUTABLE ${URBI_EXECUTABLE}")

# ======= #
# Version #
# ======= #

# Compute the version variables using urbi.exe:
#  URBI_VERSION_STRING
#  URBI_VERSION_MAJOR
#  URBI_VERSION_MINOR
#  URBI_VERSION_PATCH
#  URBI_VERSION_RC
#  URBI_VERSION_REV
macro(urbi_version)
  if(URBI_EXECUTABLE)
    # Get the version string.
    execute_process(COMMAND ${URBI_EXECUTABLE} --version
      WORKING_DIRECTORY ${URBI_EXECUTABLE_DIR}
      TIMEOUT 5
      RESULT_VARIABLE _urbi_result
      OUTPUT_VARIABLE _urbi_out
      ERROR_VARIABLE _urbi_err
      )
    message(STATUS "URBI_EXECUTABLE out ${_urbi_out}")
    message(STATUS "URBI_EXECUTABLE err ${_urbi_err}")
    message(STATUS "URBI_EXECUTABLE res ${_urbi_result}")
    if(URBI_DEBUG)
      message(STATUS
        "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
        "urbi --version output: '${_urbi_out}'")
      message(STATUS
        "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
        "urbi --version error: '${_urbi_err}'")
      message(STATUS
        "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
        "urbi --version result: '${_urbi_result}'")
    endif(URBI_DEBUG)
    string(REGEX REPLACE ".*(Urbi version [^\n]*)\n.*" "\\1"
      URBI_VERSION_STRING "${_urbi_out}")

      message(STATUS
        "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
        "urbi version string: '${URBI_VERSION_STRING}'")

    # Extract version major, minor and patch number.
    if (URBI_VERSION_STRING MATCHES "([0-9]+)\\.([0-9]+)")
      set(URBI_VERSION_MAJOR "${CMAKE_MATCH_1}")
      set(URBI_VERSION_MINOR "${CMAKE_MATCH_2}")
      set(URBI_VERSION_PATCH 0)
    endif()
    if(URBI_DEBUG)
      message(STATUS
        "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
        "urbi version numbers: major ${URBI_VERSION_MAJOR} "
        "minor ${URBI_VERSION_MINOR} patch ${URBI_VERSION_PATCH}")
    endif(URBI_DEBUG)

    # Extract release candidate number if any.
    if (URBI_VERSION_STRING MATCHES "/rc-([0-9]+) ")
      set(URBI_VERSION_RC "${CMAKE_MATCH_1}")
    else()
      set(URBI_VERSION_RC 0)
    endif()
    if(URBI_DEBUG)
      message(STATUS
        "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
        "urbi release candidate numbers: ${URBI_VERSION_RC}")
    endif(URBI_DEBUG)

    # Extract revision.
    if (URBI_VERSION_STRING MATCHES "rev. ([0-9a-fA-F]+)")
      set(URBI_VERSION_REV "${CMAKE_MATCH_1}")
    endif()
    if(URBI_DEBUG)
      message(STATUS
        "[ ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE} ] "
        "urbi revision: ${URBI_VERSION_REV}")
    endif(URBI_DEBUG)

  endif(URBI_EXECUTABLE)

endmacro()

urbi_version()

# ============ #
# Finalization #
# ============ #

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Urbi DEFAULT_MSG
  URBI_VERSION_STRING
  URBI_EXECUTABLE
  URBI_INCLUDE_DIR
  URBI_LIBRARY
  URBI_UOBJECT_LIBRARY
  URBI_VERSION_MAJOR
  URBI_VERSION_REV
  )

mark_as_advanced(
  URBI_INCLUDE_DIR
  URBI_INCLUDE_DIRS
  URBI_LIBRARIES
  URBI_UOBJECT_LIBRARY
  URBI_LIBRARY
  URBI_JPEG_LIBRARY
  URBI_PORT_LIBRARY
  URBI_SCHED_LIBRARY
  URBI_EXECUTABLE
  URBI_VERSION_STRING
  URBI_VERSION_MAJOR
  URBI_VERSION_MINOR
  URBI_VERSION_PATCH
  URBI_VERSION_RC
  URBI_VERSION_REV
  )

