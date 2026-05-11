cmake_minimum_required(VERSION 3.16)
project(full_integration LANGUAGES C)

# Cycle 11 fixture — superbuild-shaped integration:
#   - root includes BLASSetup → BLAS::BLAS available
#   - one add_subdirectory consumer (mimics in-tree subprojects)
#   - one ExternalProject_Add child that reconstructs BLAS::BLAS from the
#     -D flags emitted by blas_external_project_args() (mimics subprojects
#     built as ExternalProjects from the superbuild)
# Both consumers compile and link a tiny C program calling a real BLAS
# symbol (dasum_), so a successful build proves the BLAS::BLAS plumbing
# resolves to a working library on this host.

set(MINC_TOOLKIT_BUILD ON CACHE BOOL "" FORCE)

include("${SUPERBUILD_CMAKE_DIR}/BLASSetup.cmake")

add_subdirectory(addsub_consumer)

include(ExternalProject)
blas_external_project_args(EP_BLAS_ARGS)

ExternalProject_Add(epchild
  PREFIX            "${CMAKE_BINARY_DIR}/epchild_prefix"
  SOURCE_DIR        "${CMAKE_CURRENT_SOURCE_DIR}/epchild"
  CMAKE_ARGS
    ${EP_BLAS_ARGS}
    -DSUPERBUILD_CMAKE_DIR=${SUPERBUILD_CMAKE_DIR}
    -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
  INSTALL_COMMAND   ""
  BUILD_ALWAYS      ON
)
