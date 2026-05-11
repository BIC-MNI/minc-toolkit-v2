# Models a real subproject (e.g. patch_morphology, BEaST) that depends on BLAS.
# The MINC_TOOLKIT_BUILD guard keeps it standalone-buildable: outside the
# superbuild it discovers BLAS itself; inside the superbuild it inherits the
# BLAS::BLAS target the parent already created.

if(NOT MINC_TOOLKIT_BUILD)
  find_package(BLAS REQUIRED)
  message(STATUS "SUBPROJ_RAN_FIND_PACKAGE=YES")
else()
  message(STATUS "SUBPROJ_RAN_FIND_PACKAGE=NO")
endif()

if(TARGET BLAS::BLAS)
  message(STATUS "SUBPROJ_SAW_TARGET=YES")
else()
  message(STATUS "SUBPROJ_SAW_TARGET=NO")
endif()
