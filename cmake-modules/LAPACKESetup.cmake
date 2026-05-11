# LAPACKESetup.cmake — canonical LAPACKE::LAPACKE imported target.
#
# CMake ships no FindLAPACKE module. Where lapacke.h lives, and whether the
# C interface is even available, depends on which BLAS implementation was
# selected upstream:
#
#   OpenBLAS / MKL : LAPACKE entry points live inside the same library as
#                    BLAS — the link line aliases BLAS::BLAS. The header
#                    (lapacke.h) is shipped by some packages but not all,
#                    so we still probe for it before claiming HAVE_LAPACKE.
#   Netlib / ATLAS : separate liblapacke + standalone lapacke.h header;
#                    pull both in via find_library / find_path.
#   Apple          : Accelerate exposes only the Fortran LAPACK ABI — no
#                    lapacke.h. Define a stub target with
#                    LAPACKE_VIA_ACCELERATE=0 so subprojects can guard
#                    lapacke.h includes with #ifdef HAVE_LAPACKE.
#
# Contract: LAPACKE::LAPACKE always exists after this runs (even when the C
# interface is unavailable). HAVE_LAPACKE is added to its
# INTERFACE_COMPILE_DEFINITIONS only when lapacke.h can be found; consumers
# guard their includes with `#ifdef HAVE_LAPACKE`.
#
# Called from BLASSetup.cmake after BLAS::BLAS is defined.

include_guard(GLOBAL)

function(lapacke_setup blas_preference)
  if(TARGET LAPACKE::LAPACKE)
    return()
  endif()

  if(blas_preference STREQUAL "Apple")
    add_library(LAPACKE::LAPACKE INTERFACE IMPORTED GLOBAL)
    set_target_properties(LAPACKE::LAPACKE PROPERTIES
      INTERFACE_COMPILE_DEFINITIONS "LAPACKE_VIA_ACCELERATE=0")
    message(WARNING
      "BLAS_PREFERENCE=Apple: LAPACKE C interface is not available. "
      "Subprojects using lapacke.h will not compile. "
      "Consider BLAS_PREFERENCE=OpenBLAS for LAPACKE support.")
    return()
  endif()

  if(blas_preference STREQUAL "Netlib" OR blas_preference STREQUAL "ATLAS")
    find_library(LAPACKE_LIBRARY NAMES lapacke)
    find_path(LAPACKE_INCLUDE_DIR NAMES lapacke.h)
    if(LAPACKE_LIBRARY AND LAPACKE_INCLUDE_DIR)
      find_package(LAPACK QUIET)
      add_library(LAPACKE::LAPACKE INTERFACE IMPORTED GLOBAL)
      set_target_properties(LAPACKE::LAPACKE PROPERTIES
        INTERFACE_LINK_LIBRARIES      "${LAPACKE_LIBRARY};${LAPACK_LIBRARIES};BLAS::BLAS"
        INTERFACE_INCLUDE_DIRECTORIES "${LAPACKE_INCLUDE_DIR}"
        INTERFACE_COMPILE_DEFINITIONS "HAVE_LAPACKE")
    else()
      add_library(LAPACKE::LAPACKE INTERFACE IMPORTED GLOBAL)
      message(WARNING
        "BLAS_PREFERENCE=${blas_preference}: liblapacke / lapacke.h not found. "
        "LAPACKE::LAPACKE is a stub; subprojects using lapacke.h will compile out.")
    endif()
    return()
  endif()

  # MKL / OpenBLAS / Auto: LAPACKE entry points are bundled in BLAS::BLAS.
  # Probe for the header to decide whether to advertise HAVE_LAPACKE.
  add_library(LAPACKE::LAPACKE INTERFACE IMPORTED GLOBAL)
  set_target_properties(LAPACKE::LAPACKE PROPERTIES
    INTERFACE_LINK_LIBRARIES "BLAS::BLAS")
  find_path(LAPACKE_INCLUDE_DIR NAMES lapacke.h)
  if(LAPACKE_INCLUDE_DIR)
    set_target_properties(LAPACKE::LAPACKE PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${LAPACKE_INCLUDE_DIR}"
      INTERFACE_COMPILE_DEFINITIONS "HAVE_LAPACKE")
  endif()
endfunction()
