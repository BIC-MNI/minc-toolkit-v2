#
# this module look for HDF5 (http://hdf.ncsa.uiuc.edu) support
# it will define the following values
#
# HDF5_INCLUDE_DIR  = where hdf5.h can be found
# HDF5_LIBRARY      = the library to link against (hdf5 etc)
# HDF5_FOUND        = set to true after finding the library
#

IF(EXISTS ${PROJECT_CMAKE}/Hdf5Config.cmake)
  INCLUDE(${PROJECT_CMAKE}/Hdf5Config.cmake)
ENDIF(EXISTS ${PROJECT_CMAKE}/Hdf5Config.cmake)

IF(Hdf5_INCLUDE_DIRS)

  FIND_PATH(HDF5_INCLUDE_DIR hdf5.h ${Hdf5_INCLUDE_DIRS})
  FIND_LIBRARY(HDF5_LIBRARY hdf5 ${Hdf5_LIBRARY_DIRS})

ELSE(Hdf5_INCLUDE_DIRS)

  SET(TRIAL_LIBRARY_PATHS
    $ENV{HDF5_HOME}/lib
    /usr/apps/lib
    /usr/lib 
    /usr/local/lib
    /opt/lib
    /sw/lib
    )

  SET(TRIAL_INCLUDE_PATHS
    $ENV{HDF5_HOME}/include
    /usr/apps/include
    /usr/include
    /opt/include
    /usr/local/include
    /sw/include
    )

  IF($ENV{HDF5_DIR} MATCHES "hdf")
    MESSAGE(STATUS "Using environment variable HDF5_DIR.")
    SET(TRIAL_LIBRARY_PATHS $ENV{HDF5_DIR}/lib ${TRIAL_LIBRARY_PATHS} )
    SET(TRIAL_INCLUDE_PATHS $ENV{HDF5_DIR}/include ${TRIAL_INCLUDE_PATHS} )
  ENDIF($ENV{HDF5_DIR} MATCHES "hdf")
  
  FIND_LIBRARY(HDF5_LIBRARY hdf5 ${TRIAL_LIBRARY_PATHS})
  FIND_PATH(HDF5_INCLUDE_DIR hdf5.h ${TRIAL_INCLUDE_PATHS} )

ENDIF(Hdf5_INCLUDE_DIRS)

## -----------------------------------------------------------------------------
## Assign status of the search

IF(HDF5_INCLUDE_DIR AND HDF5_LIBRARY)
  SET(HDF5_FOUND 1 CACHE BOOL "Found hdf5 library")
ELSE(HDF5_INCLUDE_DIR AND HDF5_LIBRARY)
  SET(HDF5_FOUND 0 CACHE BOOL "Not fount hdf5 library")
ENDIF(HDF5_INCLUDE_DIR AND HDF5_LIBRARY)

## -----------------------------------------------------------------------------
## Feedback

IF (HDF5_FOUND)
  IF (NOT HDF5_FIND_QUIETLY)
    MESSAGE (STATUS "Found components for HDF5")
    MESSAGE (STATUS "HDF5 library : ${HDF5_LIBRARY}")
    MESSAGE (STATUS "HDF5 headers : ${HDF5_INCLUDE_DIR}")
  ENDIF (NOT HDF5_FIND_QUIETLY)
ELSE (HDF5_FOUND)
  IF (HDF5_FIND_REQUIRED)
    MESSAGE (FATAL_ERROR "Could not find HDF5!")
  ENDIF (HDF5_FIND_REQUIRED)
ENDIF (HDF5_FOUND)

## -----------------------------------------------------------------------------
## Variables marked as advanced

MARK_AS_ADVANCED(
  HDF5_INCLUDE_DIR 
  HDF5_LIBRARY 
  HDF5_FOUND
)
