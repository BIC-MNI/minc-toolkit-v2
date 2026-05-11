# BLASSetup.cmake — superbuild-level BLAS detection and BLAS::BLAS export.
#
# Two top-level modes:
#   - BLAS_FROM_SOURCE=ON: ignore any system BLAS, build OpenBLAS from source
#     (delegated to BLASSourceBuild.cmake).
#   - BLAS_FROM_SOURCE=OFF (default): resolve BLAS_PREFERENCE
#     (Auto/OpenBLAS/MKL/Apple/Netlib) into a BLAS::BLAS IMPORTED GLOBAL
#     target so consumers (whether pulled in via add_subdirectory or built
#     as ExternalProjects) all link the same way.
#
# When BLAS_PREFERENCE=MKL, Intel oneAPI's MKLConfig.cmake config-package is
# tried first; if that succeeds, BLAS::BLAS wraps MKL::MKL and FindBLAS is
# not invoked. Otherwise we map preference -> BLA_VENDOR and use FindBLAS.

include_guard(GLOBAL)

include("${CMAKE_CURRENT_LIST_DIR}/BLASTargetShim.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/BLASVendorMap.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/BLASMKLSetup.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/BLASSourceBuild.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/BLASExternalProjectArgs.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/LAPACKESetup.cmake")

option(BLAS_FROM_SOURCE
  "Build OpenBLAS from source instead of detecting any system BLAS." OFF)

if(BLAS_FROM_SOURCE)
  setup_blas_from_source()
  # LAPACKE::LAPACKE is set up here (target exists immediately for downstream
  # checks). Root enriches it with the staged include dir and HAVE_LAPACKE
  # after build_open_blas runs — see CMakeLists.txt's BLAS_FROM_SOURCE block.
  lapacke_setup("OpenBLAS")
else()
  set(BLAS_PREFERENCE "Auto" CACHE STRING
    "Preferred BLAS implementation. One of: Auto, OpenBLAS, MKL, Apple, Netlib.")
  set_property(CACHE BLAS_PREFERENCE PROPERTY STRINGS
    Auto OpenBLAS MKL Apple Netlib)

  if(NOT BLAS_PREFERENCE MATCHES "^(Auto|OpenBLAS|MKL|Apple|Netlib)$")
    message(FATAL_ERROR
      "Invalid BLAS_PREFERENCE='${BLAS_PREFERENCE}'. "
      "Expected one of: Auto, OpenBLAS, MKL, Apple, Netlib.")
  endif()

  message(STATUS "BLAS_PREFERENCE_RESOLVED=${BLAS_PREFERENCE}")

  set(_blas_setup_done FALSE)

  if(BLAS_PREFERENCE STREQUAL "MKL")
    setup_blas_mkl(_blas_setup_done)
  endif()

  if(NOT _blas_setup_done)
    blas_vendor_from_preference("${BLAS_PREFERENCE}" BLA_VENDOR)
    message(STATUS "BLA_VENDOR_ACTUAL=[${BLA_VENDOR}]")

    find_package(BLAS QUIET)

    if(NOT BLAS_FOUND)
      message(FATAL_ERROR
        "BLASSetup: no BLAS implementation found via find_package(BLAS). "
        "Install OpenBLAS / MKL / Apple Accelerate / Netlib BLAS, or extend "
        "CMAKE_PREFIX_PATH to point at one.")
    endif()

    blas_create_target_shim("${BLAS_LIBRARIES}" "${BLAS_LINKER_FLAGS}" "${BLAS_INCLUDE_DIRS}")
  endif()
  lapacke_setup("${BLAS_PREFERENCE}")
endif()
