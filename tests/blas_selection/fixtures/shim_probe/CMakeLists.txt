cmake_minimum_required(VERSION 3.16)
project(blas_shim_probe NONE)

# Shim-only probe: verifies blas_create_target_shim() produces a BLAS::BLAS
# target from raw BLAS_LIBRARIES + BLAS_LINKER_FLAGS values, without ever
# calling find_package(BLAS). This is what runs on CMake < 3.18, where
# FindBLAS doesn't auto-create the imported target.

if(NOT DEFINED SUPERBUILD_CMAKE_DIR)
  message(FATAL_ERROR "SUPERBUILD_CMAKE_DIR must be passed by the cycle harness.")
endif()

include("${SUPERBUILD_CMAKE_DIR}/BLASTargetShim.cmake")

if(TARGET BLAS::BLAS)
  message(FATAL_ERROR "shim probe: BLAS::BLAS already exists before shim runs — fixture state is wrong.")
endif()

blas_create_target_shim("${TEST_LIBRARIES}" "${TEST_LINKER_FLAGS}")

if(NOT TARGET BLAS::BLAS)
  message(FATAL_ERROR "shim probe: BLAS::BLAS was not created by blas_create_target_shim.")
endif()

get_target_property(_libs BLAS::BLAS INTERFACE_LINK_LIBRARIES)
message(STATUS "SHIM_OK_LIBS=[${_libs}]")
