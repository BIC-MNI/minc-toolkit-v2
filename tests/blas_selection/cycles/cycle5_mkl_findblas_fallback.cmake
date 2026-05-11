# Cycle 5 — BLAS_PREFERENCE=MKL falls back to FindBLAS with BLA_VENDOR=Intel10_64lp
#           when MKLConfig.cmake is unavailable.
#
# We use CMAKE_DISABLE_FIND_PACKAGE_MKL=ON to short-circuit
# find_package(MKL CONFIG) regardless of the host's installed packages, so
# this test is deterministic on dev machines that may or may not have oneAPI
# present. rc may be non-zero (FindBLAS with BLA_VENDOR=Intel10_64lp will
# usually fail without MKL libraries installed), so assertions target only
# the BLAS_MKL_MODE / BLA_VENDOR_ACTUAL probe lines emitted before find_package.

include("${CMAKE_CURRENT_LIST_DIR}/../helpers.cmake")

run_child_configure(
  FIXTURE "${FIXTURE_DIR}"
  BUILD   "${CYCLE_BUILD_DIR}"
  ARGS
    -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
    -DBLAS_PREFERENCE=MKL
    -DCMAKE_DISABLE_FIND_PACKAGE_MKL=ON
  OUT_RC  rc
  OUT_LOG log
)

message(STATUS "child cmake log:\n${log}")

assert_substring("BLAS_MKL_MODE=[FindBLAS]"          "${log}" "cycle5/mode")
assert_substring("BLA_VENDOR_ACTUAL=[Intel10_64lp]"  "${log}" "cycle5/vendor")
