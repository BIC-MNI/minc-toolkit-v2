# Cycle 20 — LAPACKE state forwarded to ExternalProject children.
#
# Cycle 9 locked in the BLAS_* forwarding contract via blas_external_project_args().
# This cycle extends that contract to LAPACKE: children must receive enough
# information to reconstruct LAPACKE::LAPACKE without re-running detection.
# Three additional flags:
#   -DLAPACKE_LIBRARIES=<paths>      (empty when LAPACKE is bundled in BLAS)
#   -DLAPACKE_INCLUDE_DIRS=<paths>   (empty when bundled and not separately findable)
#   -DHAVE_LAPACKE=<ON|OFF>          (OFF on Apple or when lapacke.h isn't reachable)
# All three are always emitted so the child sees a uniform shape.

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
  message(FATAL_ERROR "Cycle 20: child configure failed (rc=${rc}).")
endif()

assert_substring("EP_ARG=[-DLAPACKE_LIBRARIES="    "${log}" "cycle20/lapacke-libs")
assert_substring("EP_ARG=[-DLAPACKE_INCLUDE_DIRS=" "${log}" "cycle20/lapacke-incs")
assert_substring("EP_ARG=[-DHAVE_LAPACKE="         "${log}" "cycle20/have-lapacke")
