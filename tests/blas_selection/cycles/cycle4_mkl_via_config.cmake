# Cycle 4 — BLAS_PREFERENCE=MKL routes through MKLConfig.cmake (oneAPI), not FindBLAS.
#
# Configures the probe with BLAS_PREFERENCE=MKL and MKL_DIR pointing at a
# mock MKLConfig.cmake fixture that provides MKL::MKL. Asserts that
# BLASSetup.cmake:
#   * emits BLAS_MKL_MODE=[Config] indicating the config-package path was taken
#   * defines BLAS::BLAS (verified via the probe's PROBE_OK message)
#   * does NOT fall through to the FindBLAS / vendor-mapping branch
#     (asserted via absence of any BLA_VENDOR_ACTUAL= line)

include("${CMAKE_CURRENT_LIST_DIR}/../helpers.cmake")

run_child_configure(
  FIXTURE "${FIXTURE_DIR}"
  BUILD   "${CYCLE_BUILD_DIR}"
  ARGS
    -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
    -DBLAS_PREFERENCE=MKL
    -DMKL_DIR=${MKL_MOCK_DIR}
    -DEXPECT_TARGET=BLAS::BLAS
  OUT_RC  rc
  OUT_LOG log
)

message(STATUS "child cmake log:\n${log}")

if(NOT rc EQUAL 0)
  message(FATAL_ERROR "Cycle 4: child configure failed (rc=${rc}).")
endif()

assert_substring("BLAS_MKL_MODE=[Config]"               "${log}" "cycle4/mode")
assert_substring("PROBE_OK: target BLAS::BLAS is defined" "${log}" "cycle4/probe")
assert_no_substring("BLA_VENDOR_ACTUAL="                "${log}" "cycle4/no-findblas")
