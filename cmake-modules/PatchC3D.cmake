# PatchC3D.cmake — Patch Convert3D for CMake >= 4.0 compatibility.
#
# Convert3D's top-level CMakeLists.txt uses a directory-scope LINK_LIBRARIES()
# that lists the ITKVoxBoIO and ITKPovRayIO targets. Because the itkextras
# subdirectories are pulled in with the deferred SUBDIRS() command, that list
# leaks onto the IO library targets themselves, and CMake >= 4.0 turns the
# resulting "target links to itself" into a hard error. Clear the inherited
# link libraries on those two static IO helper targets; the final executables
# (c3d/c2d and the utilities) still link ITK and the IO libs explicitly.
#
# Expects -DSOURCE_DIR=<path to Convert3D source>

foreach(mod VoxBoIO PovRayIO)
  set(_f "${SOURCE_DIR}/itkextras/${mod}/CMakeLists.txt")
  file(READ "${_f}" _c)
  if(NOT _c MATCHES "PROPERTIES LINK_LIBRARIES")
    file(APPEND "${_f}"
      "\n# CMake >= 4.0: drop the self-referential link libraries inherited from"
      "\n# the parent directory-scope LINK_LIBRARIES() (would otherwise error"
      "\n# with 'target links to itself').\n"
      "set_target_properties(ITK${mod} PROPERTIES LINK_LIBRARIES \"\")\n")
    message(STATUS "Patched C3D itkextras/${mod}/CMakeLists.txt for CMake 4.x self-link")
  endif()
endforeach()
