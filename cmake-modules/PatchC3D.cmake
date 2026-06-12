# PatchC3D.cmake — fix Convert3D for CMake 4.x (CMP0038: target links to itself)
#
# Convert3D's top CMakeLists uses the directory-wide LINK_LIBRARIES() with the
# plugin libraries (ITKVoxBoIO, ITKPovRayIO) in the list. The plugin subdirs are
# added via the legacy SUBDIRS() command, whose processing is deferred to after
# the rest of the CMakeLists is read — so the plugins inherit that link list and
# end up linking against themselves. CMake 4.x rejects this (CMP0038).
#
# Replace the directory-wide LINK_LIBRARIES with explicit per-target
# TARGET_LINK_LIBRARIES on the c3d/c2d executables, so the plugin libraries are
# no longer affected while the executables keep the same dependencies.
#
# Expects -DSOURCE_DIR=<path to Convert3D source>

set(CMAKELISTS "${SOURCE_DIR}/CMakeLists.txt")
file(READ "${CMAKELISTS}" CONTENT)

string(REPLACE
"LINK_LIBRARIES(
  cnd_adapters cnd_driver \${ITK_LIBRARIES} ITKVoxBoIO ITKPovRayIO \${FFTW3F_LIBRARY})

ADD_EXECUTABLE(c3d Convert3DMain.cxx)

ADD_EXECUTABLE(c2d Convert2DMain.cxx)"
"ADD_EXECUTABLE(c3d Convert3DMain.cxx)
ADD_EXECUTABLE(c2d Convert2DMain.cxx)
# cnd_driver (ConvertImageND) references symbols defined in cnd_adapters, so the
# provider must follow the referencer for single-pass linkers (modern GNU ld on
# e.g. Ubuntu 26.04 no longer rescans archives).
TARGET_LINK_LIBRARIES(c3d cnd_driver cnd_adapters \${ITK_LIBRARIES} ITKVoxBoIO ITKPovRayIO \${FFTW3F_LIBRARY})
TARGET_LINK_LIBRARIES(c2d cnd_driver cnd_adapters \${ITK_LIBRARIES} ITKVoxBoIO ITKPovRayIO \${FFTW3F_LIBRARY})"
CONTENT "${CONTENT}")

file(WRITE "${CMAKELISTS}" "${CONTENT}")
message(STATUS "Patched Convert3D CMakeLists.txt for CMake 4.x (CMP0038 self-link)")
