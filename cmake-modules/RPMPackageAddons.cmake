# Additional settings for building an RPM package via CPack RPM.
#
# Runtime ELF dependencies are resolved by rpmbuild's auto-requires so the
# Requires: field is generated from the actual binaries in the build
# container. The manual list below covers only deps that are used at
# runtime but never linked.

SET(CPACK_RPM_PACKAGE_GROUP "Applications/Engineering")
SET(CPACK_RPM_PACKAGE_AUTOREQPROV "yes")
SET(CPACK_RPM_PACKAGE_REQUIRES "perl, ImageMagick")
SET(CPACK_RPM_PACKAGE_RELOCATABLE OFF)
SET(CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION "/opt")
