# Cycle 7 — BLAS_FROM_SOURCE=ON ignores system BLAS detection entirely.
#
# When the user opts into building OpenBLAS from source, the superbuild must
# completely bypass system detection: no BLAS_PREFERENCE resolution, no
# FindBLAS/FindMKL probing. Asserts:
#   - BLAS_SOURCE_BUILD=ON marker emitted
#   - none of the system-detection markers (BLAS_PREFERENCE_RESOLVED=,
#     BLA_VENDOR_ACTUAL=, BLAS_MKL_MODE=) appear in the log

include("${CMAKE_CURRENT_LIST_DIR}/../helpers.cmake")

run_child_configure(
  FIXTURE "${FIXTURE_DIR}"
  BUILD   "${CYCLE_BUILD_DIR}"
  ARGS
    -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
    -DBLAS_FROM_SOURCE=ON
  OUT_RC  rc
  OUT_LOG log
)

message(STATUS "child cmake log:\n${log}")

assert_substring   ("BLAS_SOURCE_BUILD=ON"      "${log}" "cycle7/marker")
assert_no_substring("BLAS_PREFERENCE_RESOLVED=" "${log}" "cycle7/no-pref")
assert_no_substring("BLA_VENDOR_ACTUAL="        "${log}" "cycle7/no-vendor")
assert_no_substring("BLAS_MKL_MODE="            "${log}" "cycle7/no-mkl-mode")
