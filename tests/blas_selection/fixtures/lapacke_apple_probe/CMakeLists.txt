cmake_minimum_required(VERSION 3.16)
project(lapacke_apple_probe NONE)

# Cycle 19 fixture: focused unit test of lapacke_setup("Apple"). We can't
# exercise the full BLASSetup chain on Linux because find_package(BLAS) with
# BLA_VENDOR=Apple would fail. Instead we stand up a stub BLAS::BLAS, then
# include LAPACKESetup.cmake and call lapacke_setup directly. This isolates
# the Apple-branch behaviour from the surrounding detection plumbing.

if(NOT DEFINED SUPERBUILD_CMAKE_DIR)
  message(FATAL_ERROR "SUPERBUILD_CMAKE_DIR must be passed by the cycle harness.")
endif()

add_library(BLAS::BLAS INTERFACE IMPORTED GLOBAL)

include("${SUPERBUILD_CMAKE_DIR}/LAPACKESetup.cmake")
lapacke_setup("Apple")

if(NOT TARGET LAPACKE::LAPACKE)
  message(FATAL_ERROR "lapacke_setup(Apple) did not define LAPACKE::LAPACKE.")
endif()

get_target_property(_defs LAPACKE::LAPACKE INTERFACE_COMPILE_DEFINITIONS)
message(STATUS "PROBE_PROP: LAPACKE::LAPACKE.INTERFACE_COMPILE_DEFINITIONS=[${_defs}]")
