# BLASTargetShim.cmake — CMake < 3.18 compatibility for BLAS::BLAS.
#
# CMake 3.18+ FindBLAS auto-creates a BLAS::BLAS imported target alongside
# BLAS_LIBRARIES / BLAS_LINKER_FLAGS. Older CMake (3.16, 3.17) only sets
# the variables — consumers calling find_package(BLAS) then have to wire
# up the target themselves.
#
# blas_create_target_shim(<libraries> <linker_flags> [<include_dirs>])
# creates BLAS::BLAS as INTERFACE IMPORTED GLOBAL (so it crosses
# add_subdirectory boundaries) from raw values. It is idempotent: if
# BLAS::BLAS already exists (e.g. modern FindBLAS already created it),
# the call is a no-op. Empty linker_flags / include_dirs are skipped
# rather than setting empty INTERFACE_LINK_OPTIONS / INTERFACE_INCLUDE_DIRECTORIES.

include_guard(GLOBAL)

function(blas_create_target_shim libs flags)
  if(TARGET BLAS::BLAS)
    return()
  endif()
  set(includes "${ARGV2}")
  add_library(BLAS::BLAS INTERFACE IMPORTED GLOBAL)
  set_target_properties(BLAS::BLAS PROPERTIES
    INTERFACE_LINK_LIBRARIES "${libs}")
  if(flags)
    set_target_properties(BLAS::BLAS PROPERTIES
      INTERFACE_LINK_OPTIONS "${flags}")
  endif()
  if(includes)
    set_target_properties(BLAS::BLAS PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${includes}")
  endif()
endfunction()
