# BLASMKLSetup.cmake — Intel oneAPI MKL handling.
#
# Intel oneAPI ships a CMake config-package (MKLConfig.cmake) that provides
# a curated MKL::MKL imported target already wired to the right threading,
# interface (lp64/ilp64), and runtime libraries. We prefer it over FindBLAS
# when MKL is selected, because FindBLAS's MKL detection is brittle and
# misses the threading/interface nuance.
#
# Two-stage MKL setup:
#   1. try_blas_mkl_config(<out>): run find_package(MKL CONFIG); on success,
#      create BLAS::BLAS wrapping MKL::MKL and emit BLAS_MKL_MODE=[Config].
#   2. setup_blas_mkl(<out>): orchestrates step 1 and, on failure, emits
#      BLAS_MKL_MODE=[FindBLAS] so the caller's FindBLAS fallback is logged
#      with a clear marker. Use this entry-point from BLASSetup.cmake.

include_guard(GLOBAL)

include("${CMAKE_CURRENT_LIST_DIR}/BLASTargetShim.cmake")

function(try_blas_mkl_config out_var)
  find_package(MKL CONFIG QUIET)
  if(MKL_FOUND AND TARGET MKL::MKL)
    message(STATUS "BLAS_MKL_MODE=[Config]")
    set(BLAS_MKL_MODE "Config" CACHE INTERNAL "MKL resolution mode (Config|FindBLAS)")
    blas_create_target_shim("MKL::MKL" "" "")
    set(${out_var} TRUE  PARENT_SCOPE)
  else()
    set(${out_var} FALSE PARENT_SCOPE)
  endif()
endfunction()

function(setup_blas_mkl out_var)
  try_blas_mkl_config(_done)
  if(NOT _done)
    message(STATUS "BLAS_MKL_MODE=[FindBLAS]")
    set(BLAS_MKL_MODE "FindBLAS" CACHE INTERNAL "MKL resolution mode (Config|FindBLAS)")
  endif()
  set(${out_var} ${_done} PARENT_SCOPE)
endfunction()
