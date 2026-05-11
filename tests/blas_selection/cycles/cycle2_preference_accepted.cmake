# Cycle 2 — BLAS_PREFERENCE cache variable is accepted.
#
# Configures the probe fixture (optionally with -DBLAS_PREFERENCE=<value>)
# and asserts that BLASSetup.cmake reports the resolved preference via a
# status line of the form:   BLAS_PREFERENCE_RESOLVED=<value>
# When no value is passed, the default "Auto" must be reported.

include("${CMAKE_CURRENT_LIST_DIR}/../helpers.cmake")

set(child_args -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR})
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
  message(FATAL_ERROR "Cycle 2: child configure failed (rc=${rc}).")
endif()

assert_substring(
  "BLAS_PREFERENCE_RESOLVED=${EXPECT_PREFERENCE}"
  "${log}"
  "cycle2/${EXPECT_PREFERENCE}")
