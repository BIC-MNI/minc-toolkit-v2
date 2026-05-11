# Mock MKLConfig.cmake — used by the blas_selection test harness.
#
# Real Intel oneAPI ships an MKLConfig.cmake that defines MKL::MKL alongside
# many other targets. For configure-time tests we only need a stand-in that
# (a) is loadable via find_package(MKL CONFIG) and (b) produces an MKL::MKL
# imported target. No actual library backing is required because these tests
# never compile or link.

if(NOT TARGET MKL::MKL)
  add_library(MKL::MKL INTERFACE IMPORTED)
endif()
set(MKL_FOUND TRUE)
