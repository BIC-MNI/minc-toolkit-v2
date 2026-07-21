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

# Fix the static-library link order in the top-level CMakeLists.txt.
# It lists   LINK_LIBRARIES(cnd_adapters cnd_driver ...)   -- i.e. cnd_adapters
# (which DEFINES the adapter operator()s such as ScaleShiftImage<double,3>) comes
# BEFORE cnd_driver (ConvertImageND, which CALLS them). A single-pass linker
# (GNU bfd ld on Debian/older-Ubuntu/older-Fedora) processes cnd_adapters first,
# finds nothing needed yet, discards it, then pulls cnd_driver -- whose adapter
# references are now unsatisfiable: "undefined reference to
# ScaleShiftImage<double, 3u>::operator()" and ~50 similar. macOS ld and newer
# binutils rescan archives, so they link regardless. Swap to dependency order
# (consumer before provider) so it links on every toolchain.
set(_top "${SOURCE_DIR}/CMakeLists.txt")
file(READ "${_top}" _tc)
string(REPLACE "cnd_adapters cnd_driver" "cnd_driver cnd_adapters" _tc2 "${_tc}")
if(NOT _tc STREQUAL _tc2)
  file(WRITE "${_top}" "${_tc2}")
  message(STATUS "Patched C3D link order: cnd_driver before cnd_adapters")
endif()

# Same single-pass-linker problem, different pair, buried inside ${ITK_LIBRARIES}
# itself: ITK's own library list places libfftw3f.a (defines
# fftwf_set_planner_hooks) immediately BEFORE libfftw3f_threads.a (whose
# threads.c.o references it) -- backwards for a single-pass linker: ld scans
# fftw3f.a first (nothing needs that symbol yet), discards it, then pulls
# fftw3f_threads.a, whose new undefined reference to fftwf_set_planner_hooks
# can no longer be satisfied: "undefined reference to fftwf_set_planner_hooks".
#
# Can't fix this the same way as above (textual reordering), because CMake's
# link-line computation defers ANY imported target's (i.e. anything findable
# via find_package(ITK), unlike our own plain cnd_driver/cnd_adapters targets)
# transitive INTERFACE_LINK_LIBRARIES to a closure appended AFTER the *entire*
# explicit list -- verified empirically: neither an extra
# target_link_libraries() call, nor LINK_FLAGS (which actually lands before
# the object files, not after), nor wrapping just ${ITK_LIBRARIES} in
# -Wl,--start-group/--end-group moved that closure earlier; it's always last.
# Fix: open an -Wl,--start-group with NO matching --end-group. GNU ld accepts
# this and auto-closes the group at the true end of the whole command line
# ("missing --end-group; added as last command line option"), so every
# archive -- including whatever CMake's closure appends after our explicit
# list -- ends up inside the group and gets rescanned until symbols resolve.
set(_top2 "${SOURCE_DIR}/CMakeLists.txt")
file(READ "${_top2}" _fc)
string(REPLACE
  "LINK_LIBRARIES(\n  cnd_driver cnd_adapters"
  "LINK_LIBRARIES(\n  -Wl,--start-group cnd_driver cnd_adapters"
  _fc2 "${_fc}")
if(NOT _fc STREQUAL _fc2)
  file(WRITE "${_top2}" "${_fc2}")
  message(STATUS "Patched C3D: open unclosed -Wl,--start-group so ld rescans the whole link line")
endif()
