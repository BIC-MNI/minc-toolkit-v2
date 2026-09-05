# Additional settings for building an RPM package via CPack RPM.
#
# Runtime ELF dependencies are resolved by rpmbuild's auto-requires so the
# Requires: field is generated from the actual binaries in the build
# container. The manual list below covers only deps that are used at
# runtime but never linked.

SET(CPACK_RPM_PACKAGE_GROUP "Applications/Engineering")
SET(CPACK_RPM_PACKAGE_AUTOREQPROV "yes")
SET(CPACK_RPM_PACKAGE_REQUIRES "perl, ImageMagick")
# See DebianPackageAddons.cmake: the same two scripts, weakly.
#
# dnf's install_weak_deps default pulls in Recommends and Supplements, never
# Suggests, so Recommends is the one that actually reaches the user. CPack only
# gained CPACK_RPM_PACKAGE_RECOMMENDS in CMake 4.1: Fedora 44 has 4.3 and gets
# it, Fedora 42 and 43 have 3.31 and fall back to Suggests, which dnf shows but
# does not install. An older CPack ignores the variable it does not know, so the
# version test is what keeps the fallback honest rather than silent.
#
# rpmbuild's perl generator may already emit both as hard Requires, since
# AUTOREQPROV is on and both scripts are executable with a perl shebang. A weak
# declaration cannot make the package harder to install either way.
IF(CMAKE_VERSION VERSION_GREATER_EQUAL 4.1)
  SET(CPACK_RPM_PACKAGE_RECOMMENDS "perl-Math-MatrixReal, perl-Parallel-ForkManager")
ELSE()
  SET(CPACK_RPM_PACKAGE_SUGGESTS "perl-Math-MatrixReal, perl-Parallel-ForkManager")
ENDIF()
SET(CPACK_RPM_PACKAGE_RELOCATABLE OFF)
SET(CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION "/opt")
