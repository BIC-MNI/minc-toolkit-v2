# LAPACKETargetShim.cmake — reconstruct LAPACKE::LAPACKE in ExternalProject children.
#
# Symmetric to BLASTargetShim's blas_create_target_shim(): given the three
# values forwarded by blas_external_project_args() (LAPACKE_LIBRARIES,
# LAPACKE_INCLUDE_DIRS, HAVE_LAPACKE), build a LAPACKE::LAPACKE target that
# matches what the parent superbuild defined.
#
# Usage:
#   lapacke_create_target_shim(<libs> <include_dirs> <have_lapacke>)
#
# Empty <libs> means LAPACKE was bundled in BLAS::BLAS — the target is
# created as an alias-by-link of BLAS::BLAS. Non-empty <libs> means
# Netlib-style separate liblapacke; libs are added before BLAS::BLAS in
# the link line.
#
# Idempotent: if LAPACKE::LAPACKE already exists, returns immediately.

include_guard(GLOBAL)

function(lapacke_create_target_shim libs include_dirs have_lapacke)
  if(TARGET LAPACKE::LAPACKE)
    return()
  endif()
  if(NOT TARGET BLAS::BLAS)
    message(FATAL_ERROR
      "lapacke_create_target_shim: BLAS::BLAS must exist before reconstructing LAPACKE::LAPACKE.")
  endif()
  add_library(LAPACKE::LAPACKE INTERFACE IMPORTED GLOBAL)
  if(libs)
    set_target_properties(LAPACKE::LAPACKE PROPERTIES
      INTERFACE_LINK_LIBRARIES "${libs};BLAS::BLAS")
  else()
    set_target_properties(LAPACKE::LAPACKE PROPERTIES
      INTERFACE_LINK_LIBRARIES "BLAS::BLAS")
  endif()
  if(include_dirs)
    set_target_properties(LAPACKE::LAPACKE PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${include_dirs}")
  endif()
  if(have_lapacke)
    set_target_properties(LAPACKE::LAPACKE PROPERTIES
      INTERFACE_COMPILE_DEFINITIONS "HAVE_LAPACKE")
  endif()
endfunction()
