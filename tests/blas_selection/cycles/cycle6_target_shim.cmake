# Cycle 6 — BLAS::BLAS target shim (CMake < 3.18 compatibility).
#
# Drives the shim_probe fixture, which never calls find_package(BLAS) and
# instead invokes blas_create_target_shim() with synthetic BLAS_LIBRARIES /
# BLAS_LINKER_FLAGS values. This exercises the fallback path that older
# CMake versions take, where FindBLAS doesn't auto-create BLAS::BLAS.

include("${CMAKE_CURRENT_LIST_DIR}/../helpers.cmake")

run_child_configure(
  FIXTURE "${FIXTURE_DIR}"
  BUILD   "${CYCLE_BUILD_DIR}"
  ARGS
    -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
    -DTEST_LIBRARIES=fake_blas_lib
    -DTEST_LINKER_FLAGS=
  OUT_RC  rc
  OUT_LOG log
)

message(STATUS "child cmake log:\n${log}")

if(NOT rc EQUAL 0)
  message(FATAL_ERROR "Cycle 6: child configure failed (rc=${rc}).")
endif()

assert_substring("SHIM_OK_LIBS=[fake_blas_lib]" "${log}" "cycle6/libs")
