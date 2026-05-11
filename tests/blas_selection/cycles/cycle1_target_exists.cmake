# Cycle 1 — Canonical BLAS::BLAS target (Auto mode).
#
# Configures the probe fixture with no BLAS_PREFERENCE set and asserts that
# BLAS::BLAS is defined as a target after BLASSetup.cmake has been included.

include("${CMAKE_CURRENT_LIST_DIR}/../helpers.cmake")

run_child_configure(
  FIXTURE "${FIXTURE_DIR}"
  BUILD   "${CYCLE_BUILD_DIR}"
  ARGS
    -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
    -DEXPECT_TARGET=${EXPECT_TARGET}
  OUT_RC  rc
  OUT_LOG log
)

message(STATUS "child cmake log:\n${log}")

if(NOT rc EQUAL 0)
  message(FATAL_ERROR
    "Cycle 1: child configure failed (rc=${rc}). "
    "Expected ${EXPECT_TARGET} to be defined by BLASSetup.cmake.")
endif()

assert_substring("PROBE_OK: target ${EXPECT_TARGET} is defined" "${log}" "cycle1")
