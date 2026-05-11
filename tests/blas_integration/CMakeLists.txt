cmake_minimum_required(VERSION 3.16)
project(blas_integration_tests NONE)

# Standalone test harness for the superbuild's BLAS plumbing.
# Configures and *builds* a fixture project that exercises both an
# add_subdirectory consumer and an ExternalProject_Add child linking
# against BLAS::BLAS, then asserts both binaries exist. Run with:
#   cmake -S tests/blas_integration -B tests/blas_integration/build
#   ctest --test-dir tests/blas_integration/build -V

enable_testing()

if(NOT DEFINED SUPERBUILD_SOURCE_DIR)
  get_filename_component(SUPERBUILD_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../.." ABSOLUTE)
endif()

set(SUPERBUILD_CMAKE_DIR "${SUPERBUILD_SOURCE_DIR}/cmake-modules")
set(FIXTURE_DIR          "${CMAKE_CURRENT_SOURCE_DIR}/fixture")

# One sub-test per BLAS_PREFERENCE value commonly available on Linux CI.
# MKL and Apple are skipped because they require host-specific installs.
foreach(_pref Auto OpenBLAS Netlib)
  string(TOLOWER "${_pref}" _lower)
  add_test(
    NAME blas_integration_${_lower}
    COMMAND ${CMAKE_COMMAND}
      -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
      -DFIXTURE_DIR=${FIXTURE_DIR}
      -DCYCLE_BUILD_DIR=${CMAKE_CURRENT_BINARY_DIR}/${_lower}
      -DBLAS_PREFERENCE_VALUE=${_pref}
      -P ${CMAKE_CURRENT_SOURCE_DIR}/blas_integration.cmake
  )
endforeach()
