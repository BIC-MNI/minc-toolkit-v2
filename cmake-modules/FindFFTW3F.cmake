# - Try to find FFTW single precision
# Once done this will define
#  FFTW3F_FOUND - System has FFTW3F
#  FFTW3F_INCLUDE_DIRS - The FFTW3F include directories
#  FFTW3F_LIBRARIES - The libraries needed to use FFTW3F
#  FFTW3F_DEFINITIONS - Compiler switches required for using FFTW3F

#find_package(PkgConfig)

#pkg_check_modules(PC_FFTW3F QUIET fftw3f)

#set(FFTW3F_DEFINITIONS ${PC_FFTW3F_CFLAGS_OTHER})

find_path(FFTW3F_INCLUDE_DIR fftw3.h
          NAMES fftw3.h )

find_library(FFTW3F_LIBRARY NAMES fftw3f libfftw3f )
find_library(FFTW3F_THREADS_LIBRARY NAMES fftw3_threads libfftw3f_threads )
find_library(FFTW3F_OMP_LIBRARY NAMES fftw3_omp libfftw3f_omp )

set(FFTW3F_LIBRARIES ${FFTW3F_LIBRARY} )
set(FFTW3F_INCLUDE_DIRS ${FFTW3F_INCLUDE_DIR} )

include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set FFTW3F_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(FFTW3F  DEFAULT_MSG
                                  FFTW3F_LIBRARY FFTW3F_THREADS_LIBRARY FFTW3F_OMP_LIBRARY FFTW3F_INCLUDE_DIR)

mark_as_advanced(FFTW3F_INCLUDE_DIR FFTW3F_LIBRARY FFTW3F_THREADS_LIBRARY FFTW3F_OMP_LIBRARY )
