# PatchITKZnzMangle.cmake
#
# ITK renames its bundled niftiio symbols to itk_* (itk_nifti_mangle.h, included
# from ITK's nifti1.h) but never did the same for znzlib, so ITKznz exports the
# plain znzopen/znzread/znzseek/... names. Anything that links ITK next to a
# second znzlib -- a system nifti_clib, or our own -- gets two definitions of
# each: no link error, but ITK's copies land in the executable's dynamic symbol
# table and interpose over the other library's.
#
# This applies the missing half, mirroring what ITK already does for niftiio:
# drop itk_znzlib_mangle.h beside znzlib.h and include it from there.
#
# Submitted upstream as InsightSoftwareConsortium/ITK#6756; drop this once the
# pinned ITK carries the fix itself.
#
# Expects: -DSRC=<ITK source dir>  -DMANGLE=<path to itk_znzlib_mangle.h>

if(NOT EXISTS "${MANGLE}")
  message(FATAL_ERROR "PatchITKZnzMangle: mangle header not found: ${MANGLE}")
endif()

set(_znzdir "${SRC}/Modules/ThirdParty/NIFTI/src/nifti/znzlib")
set(_znzhdr "${_znzdir}/znzlib.h")

if(NOT EXISTS "${_znzhdr}")
  message(FATAL_ERROR "PatchITKZnzMangle: header not found: ${_znzhdr}")
endif()

configure_file("${MANGLE}" "${_znzdir}/itk_znzlib_mangle.h" COPYONLY)

file(READ "${_znzhdr}" _orig)
if(_orig MATCHES "itk_znzlib_mangle\\.h")
  message(STATUS "PatchITKZnzMangle: ${_znzhdr} already patched")
else()
  # Insert at the same point nifti1.h includes itk_nifti_mangle.h: after the
  # descriptive comment, immediately before the extern "C" block. The mangle
  # defines must precede both the declarations here and znzlib.c's definitions,
  # which is satisfied by anything above this line.
  set(_anchor "/*=================*/\n#ifdef  __cplusplus\nextern \"C\" {")
  string(FIND "${_orig}" "${_anchor}" _pos)
  if(_pos EQUAL -1)
    message(FATAL_ERROR
      "PatchITKZnzMangle: could not find the extern \"C\" anchor in ${_znzhdr}; "
      "the pinned ITK has changed and this patch needs revisiting")
  endif()
  string(REPLACE "${_anchor}"
    "// Name mangling, specific to the version of znzlib included with ITK.\n#include \"itk_znzlib_mangle.h\"\n\n${_anchor}"
    _patched "${_orig}")
  file(WRITE "${_znzhdr}" "${_patched}")
  message(STATUS "PatchITKZnzMangle: prefixed znzlib symbols in ${_znzhdr}")
endif()
