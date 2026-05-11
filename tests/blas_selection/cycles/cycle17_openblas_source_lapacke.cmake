# Cycle 17 — Source-built OpenBLAS opts in to LAPACKE.
#
# Two assertions:
#   1. cmake-modules/BuildOpenBLAS.cmake's ExternalProject_Add CMAKE_ARGS
#      contains -DLAPACKE=ON. Without it, the resulting libopenblas.so omits
#      the LAPACKE C interface and consumers that include <lapacke.h> can't
#      link against the from-source build.
#   2. After include(BLASSetup) with BLAS_FROM_SOURCE=ON, LAPACKE::LAPACKE
#      is a defined imported target (alias of BLAS::BLAS). This locks the
#      from-source path to the same target contract as the system path.

include("${CMAKE_CURRENT_LIST_DIR}/../helpers.cmake")

# Static check on the BuildOpenBLAS.cmake source itself.
file(READ "${BUILD_OPENBLAS_CMAKE}" _build_openblas)
string(FIND "${_build_openblas}" "-DLAPACKE" _idx)
if(_idx EQUAL -1)
  message(FATAL_ERROR
    "Cycle 17: BuildOpenBLAS.cmake does not pass -DLAPACKE=ON to OpenBLAS's "
    "ExternalProject_Add. The source build will produce a libopenblas without "
    "the LAPACKE C interface.")
endif()

# Probe verifies LAPACKE::LAPACKE materialises after the from-source routing.
run_child_configure(
  FIXTURE "${FIXTURE_DIR}"
  BUILD   "${CYCLE_BUILD_DIR}"
  ARGS
    -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
    -DBLAS_FROM_SOURCE=ON
    -DEXPECT_TARGET=LAPACKE::LAPACKE
  OUT_RC  rc
  OUT_LOG log
)

message(STATUS "child cmake log:\n${log}")

if(NOT rc EQUAL 0)
  message(FATAL_ERROR "Cycle 17: probe configure failed (rc=${rc}).")
endif()

assert_substring("PROBE_OK: target LAPACKE::LAPACKE is defined" "${log}" "cycle17/target")
