# - Try to find FFTW
# Once done this will define
#  FFTW_FOUND - System has FFTW3
#  FFTW_INCLUDE_DIRS - The FFTW3 include directories
#  FFTW_LIBRARIES - The libraries needed to use FFTW3
#  FFTW_DEFINITIONS - Compiler switches required for using FFTW3

find_package(PkgConfig)

pkg_check_modules(PC_GSL QUIET gsl)

set(GSL_DEFINITIONS ${PC_GSL_CFLAGS_OTHER})

find_path(GSL_INCLUDE_DIR gsl/gsl_vector.h
          HINTS ${PC_GSL_INCLUDEDIR} ${PC_GSL_INCLUDE_DIRS}
          #PATH_SUFFIXES 
          )

find_library(GSL_LIBRARY NAMES gsl libgsl
             HINTS ${PC_GSL_LIBDIR} ${PC_GSL_LIBRARY_DIRS} )

find_library(GSL_CBLAS_LIBRARY NAMES gslcblas libgslcblas
             HINTS ${PC_GSL_LIBDIR} ${PC_GSL_LIBRARY_DIRS} )

set(GSL_LIBRARIES ${GSL_LIBRARY} ${GSL_CBLAS_LIBRARY})
set(GSL_INCLUDE_DIRS ${GSL_INCLUDE_DIR} )

include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set GSL_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(GSL  DEFAULT_MSG
                                  GSL_LIBRARY GSL_INCLUDE_DIR)

mark_as_advanced(GSL_INCLUDE_DIR GSL_LIBRARY GSL_CBLAS_LIBRARY )