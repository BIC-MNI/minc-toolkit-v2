cmake_minimum_required(VERSION 3.16)
project(blas_selection_tests NONE)

# Self-contained test harness for the BLAS selection logic.
# Each test spawns a child `cmake` configure on a tiny fixture project,
# captures stdout/stderr/exit-code, and asserts. Run with:
#   cmake -S tests/blas_selection -B tests/blas_selection/build
#   ctest --test-dir tests/blas_selection/build -V

enable_testing()

if(NOT DEFINED SUPERBUILD_SOURCE_DIR)
  get_filename_component(SUPERBUILD_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../.." ABSOLUTE)
endif()

set(SUPERBUILD_CMAKE_DIR "${SUPERBUILD_SOURCE_DIR}/cmake-modules")
set(FIXTURES_DIR         "${CMAKE_CURRENT_SOURCE_DIR}/fixtures")
set(CYCLES_DIR           "${CMAKE_CURRENT_SOURCE_DIR}/cycles")

# --- Cycle 1: BLAS::BLAS exists when no BLAS_PREFERENCE is set (Auto) ---
add_test(
  NAME cycle1_target_exists_auto
  COMMAND ${CMAKE_COMMAND}
    -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
    -DFIXTURE_DIR=${FIXTURES_DIR}/probe
    -DCYCLE_BUILD_DIR=${CMAKE_CURRENT_BINARY_DIR}/cycle1_auto
    -DEXPECT_TARGET=BLAS::BLAS
    -P ${CYCLES_DIR}/cycle1_target_exists.cmake
)

# --- Cycle 2: BLAS_PREFERENCE cache variable accepted; default is Auto ---
add_test(
  NAME cycle2_preference_default_auto
  COMMAND ${CMAKE_COMMAND}
    -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
    -DFIXTURE_DIR=${FIXTURES_DIR}/probe
    -DCYCLE_BUILD_DIR=${CMAKE_CURRENT_BINARY_DIR}/cycle2_default
    -DEXPECT_PREFERENCE=Auto
    -P ${CYCLES_DIR}/cycle2_preference_accepted.cmake
)

add_test(
  NAME cycle2_preference_openblas
  COMMAND ${CMAKE_COMMAND}
    -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
    -DFIXTURE_DIR=${FIXTURES_DIR}/probe
    -DCYCLE_BUILD_DIR=${CMAKE_CURRENT_BINARY_DIR}/cycle2_openblas
    -DBLAS_PREFERENCE_VALUE=OpenBLAS
    -DEXPECT_PREFERENCE=OpenBLAS
    -P ${CYCLES_DIR}/cycle2_preference_accepted.cmake
)

# --- Cycle 3: BLA_VENDOR derived from BLAS_PREFERENCE for non-MKL prefs ---
# Auto -> empty (let CMake/FindBLAS choose); OpenBLAS -> OpenBLAS;
# Apple -> Apple; Netlib -> Generic. The probe emits BLA_VENDOR_ACTUAL=[...]
# before find_package(BLAS), so these tests don't require the vendor to be
# installed on the host.
add_test(
  NAME cycle3_vendor_auto
  COMMAND ${CMAKE_COMMAND}
    -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
    -DFIXTURE_DIR=${FIXTURES_DIR}/probe
    -DCYCLE_BUILD_DIR=${CMAKE_CURRENT_BINARY_DIR}/cycle3_auto
    -DBLAS_PREFERENCE_VALUE=Auto
    -DEXPECT_VENDOR=
    -P ${CYCLES_DIR}/cycle3_bla_vendor.cmake
)

add_test(
  NAME cycle3_vendor_openblas
  COMMAND ${CMAKE_COMMAND}
    -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
    -DFIXTURE_DIR=${FIXTURES_DIR}/probe
    -DCYCLE_BUILD_DIR=${CMAKE_CURRENT_BINARY_DIR}/cycle3_openblas
    -DBLAS_PREFERENCE_VALUE=OpenBLAS
    -DEXPECT_VENDOR=OpenBLAS
    -P ${CYCLES_DIR}/cycle3_bla_vendor.cmake
)

add_test(
  NAME cycle3_vendor_apple
  COMMAND ${CMAKE_COMMAND}
    -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
    -DFIXTURE_DIR=${FIXTURES_DIR}/probe
    -DCYCLE_BUILD_DIR=${CMAKE_CURRENT_BINARY_DIR}/cycle3_apple
    -DBLAS_PREFERENCE_VALUE=Apple
    -DEXPECT_VENDOR=Apple
    -P ${CYCLES_DIR}/cycle3_bla_vendor.cmake
)

add_test(
  NAME cycle3_vendor_netlib
  COMMAND ${CMAKE_COMMAND}
    -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
    -DFIXTURE_DIR=${FIXTURES_DIR}/probe
    -DCYCLE_BUILD_DIR=${CMAKE_CURRENT_BINARY_DIR}/cycle3_netlib
    -DBLAS_PREFERENCE_VALUE=Netlib
    -DEXPECT_VENDOR=Generic
    -P ${CYCLES_DIR}/cycle3_bla_vendor.cmake
)

# --- Cycle 4: BLAS_PREFERENCE=MKL routes through MKLConfig.cmake ---
add_test(
  NAME cycle4_mkl_via_config
  COMMAND ${CMAKE_COMMAND}
    -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
    -DFIXTURE_DIR=${FIXTURES_DIR}/probe
    -DCYCLE_BUILD_DIR=${CMAKE_CURRENT_BINARY_DIR}/cycle4_mkl
    -DMKL_MOCK_DIR=${FIXTURES_DIR}/mkl_mock
    -P ${CYCLES_DIR}/cycle4_mkl_via_config.cmake
)

# --- Cycle 5: BLAS_PREFERENCE=MKL falls back to FindBLAS w/ Intel10_64lp ---
add_test(
  NAME cycle5_mkl_findblas_fallback
  COMMAND ${CMAKE_COMMAND}
    -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
    -DFIXTURE_DIR=${FIXTURES_DIR}/probe
    -DCYCLE_BUILD_DIR=${CMAKE_CURRENT_BINARY_DIR}/cycle5_mkl_fallback
    -P ${CYCLES_DIR}/cycle5_mkl_findblas_fallback.cmake
)

# --- Cycle 6: BLAS::BLAS shim is callable in isolation (CMake < 3.18 path) ---
add_test(
  NAME cycle6_target_shim
  COMMAND ${CMAKE_COMMAND}
    -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
    -DFIXTURE_DIR=${FIXTURES_DIR}/shim_probe
    -DCYCLE_BUILD_DIR=${CMAKE_CURRENT_BINARY_DIR}/cycle6_shim
    -P ${CYCLES_DIR}/cycle6_target_shim.cmake
)

# --- Cycle 7: BLAS_FROM_SOURCE=ON ignores system BLAS detection entirely ---
add_test(
  NAME cycle7_blas_from_source
  COMMAND ${CMAKE_COMMAND}
    -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
    -DFIXTURE_DIR=${FIXTURES_DIR}/probe
    -DCYCLE_BUILD_DIR=${CMAKE_CURRENT_BINARY_DIR}/cycle7_from_source
    -P ${CYCLES_DIR}/cycle7_blas_from_source.cmake
)

# --- Cycle 8: add_subdirectory consumer sees BLAS::BLAS, no double find_package ---
add_test(
  NAME cycle8_subproj_consumer
  COMMAND ${CMAKE_COMMAND}
    -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
    -DFIXTURE_DIR=${FIXTURES_DIR}/subproj_consumer
    -DCYCLE_BUILD_DIR=${CMAKE_CURRENT_BINARY_DIR}/cycle8_subproj
    -P ${CYCLES_DIR}/cycle8_subproj_consumer.cmake
)

# --- Cycle 9: blas_external_project_args() forwards FindBLAS + MKL state ---
add_test(
  NAME cycle9_external_project_args
  COMMAND ${CMAKE_COMMAND}
    -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
    -DFIXTURE_DIR=${FIXTURES_DIR}/epargs_probe
    -DCYCLE_BUILD_DIR=${CMAKE_CURRENT_BINARY_DIR}/cycle9_epargs
    -P ${CYCLES_DIR}/cycle9_external_project_args.cmake
)

# --- Cycle 10: invalid BLAS_PREFERENCE rejected with FATAL_ERROR ---
add_test(
  NAME cycle10_invalid_preference
  COMMAND ${CMAKE_COMMAND}
    -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
    -DFIXTURE_DIR=${FIXTURES_DIR}/probe
    -DCYCLE_BUILD_DIR=${CMAKE_CURRENT_BINARY_DIR}/cycle10_invalid
    -P ${CYCLES_DIR}/cycle10_invalid_preference.cmake
)

# --- Cycle 20: LAPACKE state forwarded via blas_external_project_args() ---
add_test(
  NAME cycle20_lapacke_ep_args
  COMMAND ${CMAKE_COMMAND}
    -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
    -DFIXTURE_DIR=${FIXTURES_DIR}/epargs_probe
    -DCYCLE_BUILD_DIR=${CMAKE_CURRENT_BINARY_DIR}/cycle20
    -P ${CYCLES_DIR}/cycle20_lapacke_ep_args.cmake
)

# --- Cycle 19: Apple Accelerate emits warning, defines LAPACKE_VIA_ACCELERATE=0 ---
add_test(
  NAME cycle19_apple_lapacke_warning
  COMMAND ${CMAKE_COMMAND}
    -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
    -DFIXTURE_DIR=${FIXTURES_DIR}/lapacke_apple_probe
    -DCYCLE_BUILD_DIR=${CMAKE_CURRENT_BINARY_DIR}/cycle19
    -P ${CYCLES_DIR}/cycle19_apple_lapacke_warning.cmake
)

# --- Cycle 18: Netlib finds liblapacke separately (sandboxed) ---
add_test(
  NAME cycle18_netlib_lapacke
  COMMAND ${CMAKE_COMMAND}
    -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
    -DFIXTURE_DIR=${FIXTURES_DIR}/probe
    -DCYCLE_BUILD_DIR=${CMAKE_CURRENT_BINARY_DIR}/cycle18
    -P ${CYCLES_DIR}/cycle18_netlib_lapacke.cmake
)

# --- Cycle 17: from-source OpenBLAS includes LAPACKE ---
add_test(
  NAME cycle17_openblas_source_lapacke
  COMMAND ${CMAKE_COMMAND}
    -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
    -DBUILD_OPENBLAS_CMAKE=${SUPERBUILD_SOURCE_DIR}/cmake-modules/BuildOpenBLAS.cmake
    -DFIXTURE_DIR=${FIXTURES_DIR}/probe
    -DCYCLE_BUILD_DIR=${CMAKE_CURRENT_BINARY_DIR}/cycle17
    -P ${CYCLES_DIR}/cycle17_openblas_source_lapacke.cmake
)

# --- Cycle 16: LAPACKE::LAPACKE target after BLASSetup ---
# Auto + OpenBLAS verify the bundled-LAPACKE alias path. Netlib goes through
# Cycle 18 with a sandboxed stub library — the host doesn't ship liblapacke.
foreach(_pref Auto OpenBLAS)
  string(TOLOWER "${_pref}" _lower)
  add_test(
    NAME cycle16_lapacke_target_${_lower}
    COMMAND ${CMAKE_COMMAND}
      -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
      -DFIXTURE_DIR=${FIXTURES_DIR}/probe
      -DCYCLE_BUILD_DIR=${CMAKE_CURRENT_BINARY_DIR}/cycle16_${_lower}
      -DBLAS_PREFERENCE_VALUE=${_pref}
      -P ${CYCLES_DIR}/cycle16_lapacke_target.cmake
  )
endforeach()

# --- Cycle 11: full integration — both consumer modes link real BLAS ---
# One sub-test per BLAS_PREFERENCE value present on this CI host. Auto,
# OpenBLAS and Netlib are the three commonly available on Linux. MKL and
# Apple are skipped here because they require host-specific installs not
# present in the standard test environment.
foreach(_pref Auto OpenBLAS Netlib)
  string(TOLOWER "${_pref}" _lower)
  add_test(
    NAME cycle11_full_integration_${_lower}
    COMMAND ${CMAKE_COMMAND}
      -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
      -DFIXTURE_DIR=${FIXTURES_DIR}/full_integration
      -DCYCLE_BUILD_DIR=${CMAKE_CURRENT_BINARY_DIR}/cycle11_${_lower}
      -DBLAS_PREFERENCE_VALUE=${_pref}
      -P ${CYCLES_DIR}/cycle11_full_integration.cmake
  )
endforeach()
