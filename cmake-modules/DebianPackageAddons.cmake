# Additional settings for building a Debian package via CPack DEB.
#
# Runtime ELF dependencies are resolved via dpkg-shlibdeps so the Depends:
# field is generated correctly per-distro from the actual binaries linked
# in the build container. The manual list below covers only deps that are
# used at runtime but never linked (so shlibdeps cannot find them).

SET(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
SET(CPACK_DEBIAN_PACKAGE_GENERATE_SHLIBS ON)
SET(CPACK_DEBIAN_PACKAGE_DEPENDS "perl, imagemagick")
# Two scripts out of the several hundred installed need CPAN modules:
# xfmdecomp.pl needs Math::MatrixReal, patch_segmentation_pipeline.pl needs
# Parallel::ForkManager. Everything else works without them, so these are
# Recommends rather than Depends -- apt installs them by default, and the
# package stays installable where they are not available.
SET(CPACK_DEBIAN_PACKAGE_RECOMMENDS "libmath-matrixreal-perl, libparallel-forkmanager-perl")
SET(CPACK_DEBIAN_PACKAGE_SECTION "science")
SET(CPACK_DEBIAN_PACKAGE_PRIORITY "optional")
