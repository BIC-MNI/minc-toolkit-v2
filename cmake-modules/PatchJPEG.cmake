# PatchJPEG.cmake — allow a universal (arm64;x86_64) libjpeg-turbo build.
#
# libjpeg-turbo's CMakeLists unconditionally aborts when CMAKE_OSX_ARCHITECTURES
# has more than one value ("contains assembly code, so it cannot be built with
# multiple values..."). That guard does not consider WITH_SIMD: we build with
# WITH_SIMD=OFF, so there is no assembly and a universal build is safe. Neutralise
# the guard by making its conditional never fire.
#
# Expects -DSOURCE_DIR=<path to libjpeg-turbo source>

set(CMAKELISTS "${SOURCE_DIR}/CMakeLists.txt")
file(READ "${CMAKELISTS}" CONTENT)

string(REPLACE
  "if(COUNT GREATER 1)"
  "if(FALSE)  # multi-arch is fine here: built with WITH_SIMD=OFF (no assembly)"
  CONTENT "${CONTENT}")

file(WRITE "${CMAKELISTS}" "${CONTENT}")
message(STATUS "Patched libjpeg-turbo CMakeLists.txt to allow universal build (WITH_SIMD=OFF)")
