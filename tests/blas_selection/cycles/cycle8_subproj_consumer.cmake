# Cycle 8 — add_subdirectory consumers see BLAS::BLAS, no double find_package.
#
# Contract: when the superbuild includes BLASSetup.cmake at top-level scope
# and sets MINC_TOOLKIT_BUILD=TRUE, an add_subdirectory()'d subproject must:
#   1. NOT re-run its own find_package(BLAS) — it inherits from the superbuild
#   2. See BLAS::BLAS as a TARGET — visibility crosses add_subdirectory
#
# The fixture's top-level CMakeLists includes BLASSetup.cmake then
# add_subdirectory(subproj). The subproj's CMakeLists encodes the standalone
# vs. superbuild fork via `if(NOT MINC_TOOLKIT_BUILD)`.

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
  message(FATAL_ERROR "Cycle 8: child configure failed (rc=${rc}).")
endif()

assert_substring("CONSUMER_HAS_TARGET=YES"     "${log}" "cycle8/top-level")
assert_substring("SUBPROJ_RAN_FIND_PACKAGE=NO" "${log}" "cycle8/no-refind")
assert_substring("SUBPROJ_SAW_TARGET=YES"      "${log}" "cycle8/visible")
