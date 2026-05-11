cmake_minimum_required(VERSION 3.16)
# C must be enabled — FindBLAS refuses to run without C/CXX/Fortran.
project(epargs_probe C)

# Probe for blas_external_project_args(): includes BLASSetup.cmake, then asks
# the macro for the list of -D flags ExternalProject_Add consumers should
# forward. Prints each flag on its own line as EP_ARG=[<flag>] so the cycle
# script can substring-assert their presence unambiguously.

if(NOT DEFINED SUPERBUILD_CMAKE_DIR)
  message(FATAL_ERROR "SUPERBUILD_CMAKE_DIR must be passed by the cycle harness.")
endif()

include("${SUPERBUILD_CMAKE_DIR}/BLASSetup.cmake")

blas_external_project_args(_ep_args)

foreach(arg IN LISTS _ep_args)
  message(STATUS "EP_ARG=[${arg}]")
endforeach()
