# Cycle 9 — blas_external_project_args(out_var) emits forwarding flags.
#
# ExternalProject_Add children can't see the parent's BLAS::BLAS target. To
# rebuild the same view of BLAS, they need the FindBLAS state and the MKL
# resolution mode forwarded as -D flags on the child's CMAKE_ARGS. The macro
# returns a list of those flags. This cycle asserts all four expected flags
# appear regardless of their value (Auto mode here, system OpenBLAS).

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
  message(FATAL_ERROR "Cycle 9: child configure failed (rc=${rc}).")
endif()

assert_substring("EP_ARG=[-DBLA_VENDOR="        "${log}" "cycle9/vendor")
assert_substring("EP_ARG=[-DBLAS_LIBRARIES="    "${log}" "cycle9/libs")
assert_substring("EP_ARG=[-DBLAS_LINKER_FLAGS=" "${log}" "cycle9/lflags")
assert_substring("EP_ARG=[-DBLAS_INCLUDE_DIRS=" "${log}" "cycle9/include-dirs")
assert_substring("EP_ARG=[-DBLAS_MKL_MODE="     "${log}" "cycle9/mkl-mode")
