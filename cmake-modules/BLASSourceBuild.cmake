# BLASSourceBuild.cmake — opt-in source-build of OpenBLAS.
#
# When BLAS_FROM_SOURCE=ON, the superbuild ignores any system BLAS entirely
# and arranges to build OpenBLAS from source. setup_blas_from_source() emits
# the BLAS_SOURCE_BUILD=ON marker (visible in configure logs) and sets
# BLA_VENDOR=OpenBLAS so blas_external_project_args() forwards a coherent
# view to ExternalProject children even before build_open_blas() runs.
#
# The actual ExternalProject_Add(OpenBLAS) wiring + shim creation lives in
# the root CMakeLists.txt — it needs CMAKE_INSTALL_PREFIX, SUPERBUILD_STAGING_PREFIX,
# and cmake-modules/ on CMAKE_MODULE_PATH, all of which are root-scope concerns.

include_guard(GLOBAL)

function(setup_blas_from_source)
  message(STATUS "BLAS_SOURCE_BUILD=ON")
  set(BLA_VENDOR "OpenBLAS" PARENT_SCOPE)
endfunction()
