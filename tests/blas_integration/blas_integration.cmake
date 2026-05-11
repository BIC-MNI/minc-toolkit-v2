# BLAS integration test — both consumer modes, real linking.
#
# Configures the fixture (which itself includes BLASSetup and exercises
# both an add_subdirectory consumer and an ExternalProject_Add child)
# and then *builds* it. The build step compiles two tiny executables
# that link against BLAS::BLAS and call dasum_, so a clean build proves
# the whole pipeline — detection, target export, add_subdirectory
# visibility, external-project arg forwarding, child-side reconstruction
# — works on the host's real BLAS install.

include("${CMAKE_CURRENT_LIST_DIR}/helpers.cmake")

set(child_args -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR})
if(BLAS_PREFERENCE_VALUE)
  list(APPEND child_args -DBLAS_PREFERENCE=${BLAS_PREFERENCE_VALUE})
endif()

run_child_configure(
  FIXTURE "${FIXTURE_DIR}"
  BUILD   "${CYCLE_BUILD_DIR}"
  ARGS    ${child_args}
  OUT_RC  rc
  OUT_LOG log
)

message(STATUS "configure log:\n${log}")

if(NOT rc EQUAL 0)
  message(FATAL_ERROR "parent configure failed (rc=${rc}).")
endif()

execute_process(
  COMMAND ${CMAKE_COMMAND} --build "${CYCLE_BUILD_DIR}"
  RESULT_VARIABLE build_rc
  OUTPUT_VARIABLE build_out
  ERROR_VARIABLE  build_err
)

set(build_log "${build_out}\n${build_err}")
message(STATUS "build log:\n${build_log}")

if(NOT build_rc EQUAL 0)
  message(FATAL_ERROR "build failed (rc=${build_rc}).")
endif()

# Both binaries must exist after the build.
set(addsub_exe "${CYCLE_BUILD_DIR}/addsub_consumer/addsub_blas_link")
set(epchild_exe "${CYCLE_BUILD_DIR}/epchild_prefix/src/epchild-build/ep_blas_link")

if(NOT EXISTS "${addsub_exe}")
  message(FATAL_ERROR "add_subdirectory binary missing: ${addsub_exe}")
endif()
if(NOT EXISTS "${epchild_exe}")
  message(FATAL_ERROR "ExternalProject child binary missing: ${epchild_exe}")
endif()
