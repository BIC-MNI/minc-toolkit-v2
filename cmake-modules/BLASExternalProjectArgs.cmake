# BLASExternalProjectArgs.cmake — forward parent BLAS+LAPACKE state to child ExternalProjects.
#
# ExternalProject_Add children configure in their own cmake invocation and
# can't see the parent's BLAS::BLAS / LAPACKE::LAPACKE targets.
# blas_external_project_args() returns a list of -D flags suitable to pass via
# the child's CMAKE_ARGS so the child can reconstruct the same view of both:
#
#   BLA_VENDOR / BLAS_LIBRARIES / BLAS_LINKER_FLAGS / BLAS_INCLUDE_DIRS
#       feed the child's find_package(BLAS) (or its blas_create_target_shim)
#       with the same resolution the parent landed on.
#   BLAS_MKL_MODE
#       tells the child whether the parent resolved MKL via MKLConfig.cmake
#       (Config) or via FindBLAS+Intel10_64lp (FindBLAS); empty when MKL
#       wasn't selected at all.
#   LAPACKE_LIBRARIES / LAPACKE_INCLUDE_DIRS
#       LAPACKE::LAPACKE properties stripped of the BLAS::BLAS chain so the
#       child can rebuild the target by alias-or-list, depending on whether
#       LAPACKE is bundled (empty libs) or separate (Netlib-style: paths).
#   HAVE_LAPACKE
#       ON when LAPACKE::LAPACKE advertises HAVE_LAPACKE on its
#       INTERFACE_COMPILE_DEFINITIONS, OFF otherwise (Apple, or hosts where
#       lapacke.h was unreachable).
#
# All flags are always emitted, even with empty values, so the child sees a
# uniform shape regardless of which path the parent took.

include_guard(GLOBAL)

function(blas_external_project_args out_var)
  # Strip BLAS::BLAS from LAPACKE's link-libs — child reconstructs that itself.
  set(_lapacke_libs "")
  if(TARGET LAPACKE::LAPACKE)
    get_target_property(_raw LAPACKE::LAPACKE INTERFACE_LINK_LIBRARIES)
    if(_raw)
      foreach(_lib IN LISTS _raw)
        if(NOT _lib STREQUAL "BLAS::BLAS")
          list(APPEND _lapacke_libs "${_lib}")
        endif()
      endforeach()
    endif()
  endif()

  set(_lapacke_incs "")
  if(TARGET LAPACKE::LAPACKE)
    get_target_property(_raw LAPACKE::LAPACKE INTERFACE_INCLUDE_DIRECTORIES)
    if(_raw)
      set(_lapacke_incs "${_raw}")
    endif()
  endif()

  set(_have_lapacke OFF)
  if(TARGET LAPACKE::LAPACKE)
    get_target_property(_raw LAPACKE::LAPACKE INTERFACE_COMPILE_DEFINITIONS)
    if(_raw)
      if("HAVE_LAPACKE" IN_LIST _raw)
        set(_have_lapacke ON)
      endif()
    endif()
  endif()

  set(${out_var}
    "-DBLA_VENDOR=${BLA_VENDOR}"
    "-DBLAS_LIBRARIES=${BLAS_LIBRARIES}"
    "-DBLAS_LINKER_FLAGS=${BLAS_LINKER_FLAGS}"
    "-DBLAS_INCLUDE_DIRS=${BLAS_INCLUDE_DIRS}"
    "-DBLAS_MKL_MODE=${BLAS_MKL_MODE}"
    "-DLAPACKE_LIBRARIES=${_lapacke_libs}"
    "-DLAPACKE_INCLUDE_DIRS=${_lapacke_incs}"
    "-DHAVE_LAPACKE=${_have_lapacke}"
    PARENT_SCOPE)
endfunction()
