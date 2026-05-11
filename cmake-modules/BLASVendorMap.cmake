# BLASVendorMap.cmake — preference → BLA_VENDOR mapping.
#
# `BLA_VENDOR` is the cache variable read by CMake's FindBLAS module to bias
# detection toward a specific implementation. We expose a friendlier
# `BLAS_PREFERENCE` knob to users and translate it to FindBLAS's vocabulary.
#
# MKL is mapped to Intel10_64lp here because that's the BLA_VENDOR used when
# falling back to FindBLAS after MKLConfig.cmake is unavailable. The
# config-package path (see BLASMKLSetup.cmake) is tried first and bypasses
# this mapping when it succeeds.

include_guard(GLOBAL)

function(blas_vendor_from_preference pref out_var)
  if(pref STREQUAL "Auto")
    set(${out_var} ""             PARENT_SCOPE)
  elseif(pref STREQUAL "OpenBLAS")
    set(${out_var} "OpenBLAS"     PARENT_SCOPE)
  elseif(pref STREQUAL "MKL")
    set(${out_var} "Intel10_64lp" PARENT_SCOPE)
  elseif(pref STREQUAL "Apple")
    set(${out_var} "Apple"        PARENT_SCOPE)
  elseif(pref STREQUAL "Netlib")
    set(${out_var} "Generic"      PARENT_SCOPE)
  else()
    set(${out_var} ""             PARENT_SCOPE)
  endif()
endfunction()
