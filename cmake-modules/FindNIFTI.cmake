# FindNIFTI.cmake module


FIND_PATH(NIFTI_INCLUDE_DIR nifti1_io.h /usr/include /usr/local/include /usr/local/bic/include)

FIND_LIBRARY(NIFTI_LIBRARY NAMES niftiio PATHS /usr/lib /usr/local/lib /usr/local/bic/lib)

FIND_PATH(ZNZ_INCLUDE_DIR znzlib.h /usr/include /usr/local/include /usr/local/bic/include)

FIND_LIBRARY(ZNZ_LIBRARY NAMES znz PATHS /usr/lib /usr/local/lib /usr/local/bic/lib)


IF (NIFTI_INCLUDE_DIR AND NIFTI_LIBRARY AND ZNZ_INCLUDE_DIR AND ZNZ_LIBRARY)
   SET(NIFTI_FOUND TRUE)
ENDIF (NIFTI_INCLUDE_DIR AND NIFTI_LIBRARY AND ZNZ_INCLUDE_DIR AND ZNZ_LIBRARY)


IF (NIFTI_FOUND)
   IF (NOT NIFTI_FIND_QUIETLY)
      MESSAGE(STATUS "Found NetCDF headers: ${NIFTI_INCLUDE_DIR}")
      MESSAGE(STATUS "Found NetCDF library: ${NIFTI_LIBRARY}")
      MESSAGE(STATUS "Found znzlib headers: ${ZNZ_INCLUDE_DIR}")
      MESSAGE(STATUS "Found znzlib library: ${ZNZ_LIBRARY}")
   ENDIF (NOT NIFTI_FIND_QUIETLY)
ELSE (NIFTI_FOUND)
   IF (NIFTI_FIND_REQUIRED)
      MESSAGE(FATAL_ERROR "Cound not find NIfTI-1 I/O library")
   ENDIF (NIFTI_FIND_REQUIRED)
ENDIF (NIFTI_FOUND)
