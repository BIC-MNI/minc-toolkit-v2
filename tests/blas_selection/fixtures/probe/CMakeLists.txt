cmake_minimum_required(VERSION 3.16)
# C must be enabled — FindBLAS refuses to run without C/CXX/Fortran.
project(blas_probe C)

# Generic probe fixture used by most cycles.
# The cycle script passes:
#   -DSUPERBUILD_CMAKE_DIR=...   path to the superbuild's cmake/ directory
#   -DEXPECT_TARGET=BLAS::BLAS   (optional) target that must exist after include
# and may pass -DBLAS_PREFERENCE=... or other knobs that BLASSetup.cmake reads.

if(NOT DEFINED SUPERBUILD_CMAKE_DIR)
  message(FATAL_ERROR "SUPERBUILD_CMAKE_DIR must be passed by the cycle harness.")
endif()

include("${SUPERBUILD_CMAKE_DIR}/BLASSetup.cmake")

if(EXPECT_TARGET)
  if(NOT TARGET ${EXPECT_TARGET})
    message(FATAL_ERROR "Expected target '${EXPECT_TARGET}' to be defined after BLASSetup.cmake, but it was not.")
  endif()
  message(STATUS "PROBE_OK: target ${EXPECT_TARGET} is defined")
endif()

if(DUMP_TARGET_PROPERTIES)
  if(NOT TARGET ${DUMP_TARGET_PROPERTIES})
    message(FATAL_ERROR "DUMP_TARGET_PROPERTIES='${DUMP_TARGET_PROPERTIES}' is not a target.")
  endif()
  foreach(prop INTERFACE_LINK_LIBRARIES INTERFACE_INCLUDE_DIRECTORIES INTERFACE_COMPILE_DEFINITIONS)
    get_target_property(_v ${DUMP_TARGET_PROPERTIES} ${prop})
    message(STATUS "PROBE_PROP: ${DUMP_TARGET_PROPERTIES}.${prop}=[${_v}]")
  endforeach()
endif()
