# Cycle 3 — BLA_VENDOR derived from BLAS_PREFERENCE for non-MKL preferences.
#
# Configures the probe fixture with -DBLAS_PREFERENCE=<value> and asserts that
# BLASSetup.cmake emits a status line:    BLA_VENDOR_ACTUAL=[<vendor>]
# *before* it calls find_package(BLAS), so the assertion holds even when the
# requested vendor isn't installed on the host (e.g. Apple on Linux). We do
# NOT require rc=0 for that reason — the mapping is what's under test, not
# whether the host has the library.
#
# The bracket-wrapping `[${BLA_VENDOR}]` disambiguates the empty value
# (BLA_VENDOR_ACTUAL=[]) from a populated one (BLA_VENDOR_ACTUAL=[OpenBLAS]),
# which a naive substring check on `BLA_VENDOR_ACTUAL=` would conflate.

include("${CMAKE_CURRENT_LIST_DIR}/../helpers.cmake")

set(child_args -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR})
if(DEFINED BLAS_PREFERENCE_VALUE)
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

assert_substring(
  "BLA_VENDOR_ACTUAL=[${EXPECT_VENDOR}]"
  "${log}"
  "cycle3/${BLAS_PREFERENCE_VALUE}")
