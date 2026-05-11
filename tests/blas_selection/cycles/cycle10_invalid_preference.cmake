# Cycle 10 — invalid BLAS_PREFERENCE is rejected with FATAL_ERROR.
#
# BLAS_PREFERENCE is a STRINGS-restricted cache var (Auto|OpenBLAS|MKL|Apple|
# Netlib). cache STRINGS only enforces values in the GUI; from the command
# line a typo silently falls through. To prevent a typo from being treated as
# Auto (and surprising the user with an unexpected vendor), BLASSetup.cmake
# must validate the value early and FATAL_ERROR with a clear marker.

include("${CMAKE_CURRENT_LIST_DIR}/../helpers.cmake")

run_child_configure(
  FIXTURE "${FIXTURE_DIR}"
  BUILD   "${CYCLE_BUILD_DIR}"
  ARGS
    -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
    -DBLAS_PREFERENCE=GarbageValue
  OUT_RC  rc
  OUT_LOG log
)

message(STATUS "child cmake log:\n${log}")

if(rc EQUAL 0)
  message(FATAL_ERROR
    "Cycle 10: child configure unexpectedly succeeded with an invalid "
    "BLAS_PREFERENCE; expected FATAL_ERROR.")
endif()

assert_substring("Invalid BLAS_PREFERENCE" "${log}" "cycle10/marker")
