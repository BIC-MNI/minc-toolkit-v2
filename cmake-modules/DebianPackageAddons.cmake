# Additional settings for building a Debian package via CPack DEB.
#
# Runtime ELF dependencies are resolved via dpkg-shlibdeps so the Depends:
# field is generated correctly per-distro from the actual binaries linked
# in the build container. The manual list below covers only deps that are
# used at runtime but never linked (so shlibdeps cannot find them).

SET(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
SET(CPACK_DEBIAN_PACKAGE_GENERATE_SHLIBS ON)
SET(CPACK_DEBIAN_PACKAGE_DEPENDS "perl, imagemagick")
SET(CPACK_DEBIAN_PACKAGE_SECTION "science")
SET(CPACK_DEBIAN_PACKAGE_PRIORITY "optional")
