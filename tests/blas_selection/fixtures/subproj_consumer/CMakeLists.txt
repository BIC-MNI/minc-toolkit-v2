cmake_minimum_required(VERSION 3.16)
# C must be enabled — FindBLAS refuses to run without C/CXX/Fortran.
project(subproj_consumer C)

# Models a superbuild that:
#   1. flags MINC_TOOLKIT_BUILD=TRUE so subprojects know they're embedded
#   2. includes BLASSetup.cmake at top-level scope (creating BLAS::BLAS)
#   3. add_subdirectory()'s a subproject that should inherit BLAS::BLAS
#      without re-running its own find_package(BLAS).

if(NOT DEFINED SUPERBUILD_CMAKE_DIR)
  message(FATAL_ERROR "SUPERBUILD_CMAKE_DIR must be passed by the cycle harness.")
endif()

set(MINC_TOOLKIT_BUILD TRUE)

include("${SUPERBUILD_CMAKE_DIR}/BLASSetup.cmake")

if(TARGET BLAS::BLAS)
  message(STATUS "CONSUMER_HAS_TARGET=YES")
else()
  message(STATUS "CONSUMER_HAS_TARGET=NO")
endif()

add_subdirectory(subproj)
