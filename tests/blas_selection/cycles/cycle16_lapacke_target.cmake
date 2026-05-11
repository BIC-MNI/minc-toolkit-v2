# Cycle 16 — LAPACKE::LAPACKE target is always defined after BLASSetup.cmake.
#
# Mirrors Cycle 1's BLAS::BLAS contract for the LAPACKE C interface. After
# include(BLASSetup), LAPACKE::LAPACKE must be a defined imported target for
# every BLAS_PREFERENCE value reachable on the host. For OpenBLAS/MKL/Auto,
# the LAPACKE entry points live in the same library as BLAS, so the target
# is an alias of BLAS::BLAS. For Netlib it is a separate library + header.
# For Apple, the target exists but advertises LAPACKE_VIA_ACCELERATE=0.

include("${CMAKE_CURRENT_LIST_DIR}/../helpers.cmake")

set(child_args
  -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
  -DEXPECT_TARGET=LAPACKE::LAPACKE)
if(BLAS_PREFERENCE_VALUE)
  list(APPEND child_args -DBLAS_PREFERENCE=${BLAS_PREFERENCE_VALUE})
endif()

run_child_configure(
  FIXTURE "${FIXTURE_DIR}"
  BUILD   "${CYCLE_BUILD_DIR}"
  ARGS    ${child_args}
  OUT_RC  rc
  OUT_LOG log
)

message(STATUS "child cmake log:\n${log}")

if(NOT rc EQUAL 0)
  message(FATAL_ERROR
    "Cycle 16: child configure failed (rc=${rc}). "
    "Expected LAPACKE::LAPACKE to be defined by BLASSetup.cmake.")
endif()

assert_substring("PROBE_OK: target LAPACKE::LAPACKE is defined" "${log}" "cycle16")
