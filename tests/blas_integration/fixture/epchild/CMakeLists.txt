cmake_minimum_required(VERSION 3.16)
project(epchild LANGUAGES C)

# ExternalProject child: receives BLA_VENDOR / BLAS_LIBRARIES /
# BLAS_LINKER_FLAGS / BLAS_MKL_MODE from the parent. Reconstructs
# BLAS::BLAS via the same shim the parent uses, so the link line is
# byte-identical regardless of which detection path the parent took.

include("${SUPERBUILD_CMAKE_DIR}/BLASTargetShim.cmake")

if(BLAS_MKL_MODE STREQUAL "Config")
  find_package(MKL CONFIG REQUIRED)
  blas_create_target_shim("MKL::MKL" "" "")
else()
  if(NOT BLAS_LIBRARIES)
    find_package(BLAS REQUIRED)
  endif()
  blas_create_target_shim("${BLAS_LIBRARIES}" "${BLAS_LINKER_FLAGS}" "${BLAS_INCLUDE_DIRS}")
endif()

if(NOT TARGET BLAS::BLAS)
  message(FATAL_ERROR "epchild: failed to reconstruct BLAS::BLAS.")
endif()

add_executable(ep_blas_link blas_link.c)
target_link_libraries(ep_blas_link PRIVATE BLAS::BLAS)
