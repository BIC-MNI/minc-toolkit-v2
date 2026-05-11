# Cycle 19 — Apple Accelerate path: warn, don't FATAL_ERROR.
#
# Accelerate exposes only the Fortran LAPACK ABI; lapacke.h and the LAPACKE_*
# C entry points don't exist. The contract is:
#   - lapacke_setup("Apple") must succeed (configure rc=0)
#   - emit a clear WARNING that LAPACKE is unavailable
#   - still create LAPACKE::LAPACKE (every BLAS_PREFERENCE branch defines it)
#     with LAPACKE_VIA_ACCELERATE=0 on INTERFACE_COMPILE_DEFINITIONS so
#     subprojects can `#ifdef HAVE_LAPACKE` (which is absent here) and
#     `#if !LAPACKE_VIA_ACCELERATE` to compile-out lapacke-using code paths.

include("${CMAKE_CURRENT_LIST_DIR}/../helpers.cmake")

run_child_configure(
  FIXTURE "${FIXTURE_DIR}"
  BUILD   "${CYCLE_BUILD_DIR}"
  ARGS
    -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
  OUT_RC  rc
  OUT_LOG log
)

message(STATUS "child cmake log:\n${log}")

if(NOT rc EQUAL 0)
  message(FATAL_ERROR
    "Cycle 19: probe configure failed (rc=${rc}) — Apple branch must NOT FATAL_ERROR.")
endif()

assert_substring("LAPACKE C interface is not available" "${log}" "cycle19/warning")
assert_substring("LAPACKE_VIA_ACCELERATE=0"            "${log}" "cycle19/define")
