# Cycle 18 — Netlib path: liblapacke is found separately from liblapack.
#
# Netlib (and ATLAS) ship LAPACKE as a separate library + standalone header
# rather than bundling it inside libblas. This test stubs both into a
# sandbox prefix and asserts that lapacke_setup() ends up with:
#   - LAPACKE::LAPACKE.INTERFACE_LINK_LIBRARIES containing the stub liblapacke
#     path, plus a chain back to BLAS::BLAS
#   - LAPACKE::LAPACKE.INTERFACE_INCLUDE_DIRECTORIES containing the sandbox
#     include directory (where the stub lapacke.h lives)
#   - LAPACKE::LAPACKE.INTERFACE_COMPILE_DEFINITIONS containing HAVE_LAPACKE
# The sandbox keeps the test hermetic — it doesn't rely on liblapacke-dev
# being installed on the host.

include("${CMAKE_CURRENT_LIST_DIR}/../helpers.cmake")

# Build the sandbox: empty .so + empty header. find_library / find_path only
# check for file existence, not contents, so empty stubs are sufficient.
set(SANDBOX "${CYCLE_BUILD_DIR}_sandbox")
file(MAKE_DIRECTORY "${SANDBOX}/lib" "${SANDBOX}/include")
file(WRITE "${SANDBOX}/lib/liblapacke.so" "")
file(WRITE "${SANDBOX}/include/lapacke.h" "")

run_child_configure(
  FIXTURE "${FIXTURE_DIR}"
  BUILD   "${CYCLE_BUILD_DIR}"
  ARGS
    -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
    -DBLAS_PREFERENCE=Netlib
    -DCMAKE_LIBRARY_PATH=${SANDBOX}/lib
    -DCMAKE_INCLUDE_PATH=${SANDBOX}/include
    -DEXPECT_TARGET=LAPACKE::LAPACKE
    -DDUMP_TARGET_PROPERTIES=LAPACKE::LAPACKE
  OUT_RC  rc
  OUT_LOG log
)

message(STATUS "child cmake log:\n${log}")

if(NOT rc EQUAL 0)
  message(FATAL_ERROR "Cycle 18: probe configure failed (rc=${rc}).")
endif()

# Sandbox library/header must show up in the resolved properties.
assert_substring("${SANDBOX}/lib/liblapacke.so"
  "${log}" "cycle18/link-lib")
assert_substring("BLAS::BLAS"
  "${log}" "cycle18/blas-chain")
assert_substring("${SANDBOX}/include"
  "${log}" "cycle18/include-dir")
assert_substring("HAVE_LAPACKE"
  "${log}" "cycle18/have-lapacke")
