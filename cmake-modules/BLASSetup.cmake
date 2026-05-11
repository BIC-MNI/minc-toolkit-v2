# BLASSetup.cmake — superbuild-level BLAS detection and BLAS::BLAS export.
#
# Three top-level modes:
#   - MT_USE_BLAS=OFF: do not detect or build any BLAS, even if a system
#     library is present. BLAS::BLAS and LAPACKE::LAPACKE are created as
#     empty stub targets and BLAS_LIBRARIES / BLAS_MKL_MODE / ... are
#     emitted as empty values to ExternalProject children, so consumers
#     that gate on those variables compile-out their BLAS-using code paths.
#   - MT_BUILD_OPENBLAS=ON: ignore any system BLAS, build OpenBLAS from source
#     (delegated to BLASSourceBuild.cmake). Requires MT_USE_BLAS=ON.
#   - MT_USE_BLAS=ON, MT_BUILD_OPENBLAS=OFF (default): resolve BLAS_PREFERENCE
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

option(MT_USE_BLAS
  "Use BLAS. If OFF, BLAS detection is skipped even if a system BLAS is present." ON)
option(MT_BUILD_OPENBLAS
  "Build OpenBLAS from source instead of detecting any system BLAS." OFF)

if(NOT MT_USE_BLAS)
  if(MT_BUILD_OPENBLAS)
    message(FATAL_ERROR
      "MT_USE_BLAS=OFF and MT_BUILD_OPENBLAS=ON are mutually exclusive. "
      "Either enable MT_USE_BLAS (to build/use BLAS) or disable MT_BUILD_OPENBLAS.")
  endif()
  message(STATUS "BLAS disabled (MT_USE_BLAS=OFF): skipping detection; stub targets only.")
  # Clear any forwarded state so blas_external_project_args() emits empty values
  # and downstream gating in EP children (e.g. patch_morphology's
  # `if(BLAS_LIBRARIES OR BLAS_MKL_MODE STREQUAL "Config")`) takes the "no BLAS"
  # branch. BLASSetup is include()'d at root scope, so these plain sets shadow
  # any value the user might have passed for -DBLAS_LIBRARIES=... on the command
  # line (which would otherwise leak through unchanged).
  set(BLA_VENDOR        "")
  set(BLAS_LIBRARIES    "")
  set(BLAS_LINKER_FLAGS "")
  set(BLAS_INCLUDE_DIRS "")
  set(BLAS_MKL_MODE     "")
  # Stub targets so `if(TARGET BLAS::BLAS)` checks elsewhere don't crash.
  # They carry no link libraries and no HAVE_LAPACKE — consumers that
  # additionally check USE_BLAS / HAVE_LAPACKE will compile-out cleanly.
  if(NOT TARGET BLAS::BLAS)
    add_library(BLAS::BLAS INTERFACE IMPORTED GLOBAL)
  endif()
  if(NOT TARGET LAPACKE::LAPACKE)
    add_library(LAPACKE::LAPACKE INTERFACE IMPORTED GLOBAL)
  endif()
  return()
endif()

if(MT_BUILD_OPENBLAS)
  setup_blas_from_source()
  # LAPACKE::LAPACKE is set up here (target exists immediately for downstream
  # checks). Root enriches it with the staged include dir and HAVE_LAPACKE
  # after build_open_blas runs — see CMakeLists.txt's MT_BUILD_OPENBLAS block.
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
