# - Find PCRE
# Find the native PCRE includes and library
# This module defines
#  PCRE_INCLUDE_DIR, where to find jpeglib.h, etc.
#  PCRE_LIBRARIES, the libraries needed to use PCRE.
#  PCRE_FOUND, If false, do not try to use PCRE.
# also defined, but not for general use are
#  PCRE_LIBRARY, where to find the PCRE library.

FIND_PATH(PCRE_INCLUDE_DIR pcre.h
/usr/local/include
/usr/include
)

SET(PCRE_NAMES ${PCRE_NAMES} pcre)
FIND_LIBRARY(PCRE_LIBRARY
  NAMES ${PCRE_NAMES}
  PATHS /usr/lib /usr/local/lib
  )

IF (PCRE_LIBRARY AND PCRE_INCLUDE_DIR)
    SET(PCRE_LIBRARIES ${PCRE_LIBRARY})
    SET(PCRE_FOUND "YES")
ELSE (PCRE_LIBRARY AND PCRE_INCLUDE_DIR)
  SET(PCRE_FOUND "NO")
ENDIF (PCRE_LIBRARY AND PCRE_INCLUDE_DIR)


IF (PCRE_FOUND)
   IF (NOT PCRE_FIND_QUIETLY)
      MESSAGE(STATUS "Found PCRE: ${PCRE_LIBRARIES}")
   ENDIF (NOT PCRE_FIND_QUIETLY)
ELSE (PCRE_FOUND)
   IF (PCRE_FIND_REQUIRED)
      MESSAGE(FATAL_ERROR "Could not find PCRE library")
   ENDIF (PCRE_FIND_REQUIRED)
ENDIF (PCRE_FOUND)

# Deprecated declarations.
SET (NATIVE_PCRE_INCLUDE_PATH ${PCRE_INCLUDE_DIR} )
GET_FILENAME_COMPONENT (NATIVE_PCRE_LIB_PATH ${PCRE_LIBRARY} PATH)

MARK_AS_ADVANCED(
  PCRE_LIBRARY
  PCRE_INCLUDE_DIR
  )

