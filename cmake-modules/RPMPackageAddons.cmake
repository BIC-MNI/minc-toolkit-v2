# Additional settings for building an RPM package via CPack RPM.
#
# Runtime ELF dependencies are resolved by rpmbuild's auto-requires so the
# Requires: field is generated from the actual binaries in the build
# container. The manual list below covers only deps that are used at
# runtime but never linked.

SET(CPACK_RPM_PACKAGE_GROUP "Applications/Engineering")
SET(CPACK_RPM_PACKAGE_AUTOREQPROV "yes")
SET(CPACK_RPM_PACKAGE_REQUIRES "perl, ImageMagick")
# See DebianPackageAddons.cmake: the same two scripts, as a weak dependency.
# rpmbuild's perl generator probably already emits these as hard Requires,
# since AUTOREQPROV is on and both scripts are executable with a perl shebang;
# stating them weakly covers the case where it does not, and a Suggests cannot
# make the package harder to install either way. CPACK_RPM_PACKAGE_RECOMMENDS
# would be the closer match, but it needs CMake 4.1, newer than the Fedora
# images this workflow builds on.
SET(CPACK_RPM_PACKAGE_SUGGESTS "perl-Math-MatrixReal, perl-Parallel-ForkManager")
SET(CPACK_RPM_PACKAGE_RELOCATABLE OFF)
SET(CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION "/opt")
