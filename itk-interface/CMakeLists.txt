#message(WARNING ${ITK_USE_FILE})
IF(EXISTS ${ITK_USE_FILE})
  INCLUDE(${ITK_USE_FILE})
ENDIF(EXISTS ${ITK_USE_FILE})

SET(ITKIOMINC_SRC
     minc4itk/src/itkMincHelpers.cxx
     minc4itk/src/itkMincImageIO.cxx
     minc4itk/src/itkMincImageIOFactory.cxx
     minc4itk/src/itkMincHelpers.cxx
)

SET(ITKIOMINC_HEADER
  minc4itk/include/itkMincImageIO.h
  minc4itk/include/itkMincTransformIOFactory.h
  minc4itk/include/itkMincTransformIO.h
  minc4itk/include/itkMincGeneralTransform.h
  minc4itk/include/itkMincHelpers.h
)

IF(ITK_VERSION_MAJOR VERSION_EQUAL 4)
  SET(ITKIOMINC_SRC
    ${ITKIOMINC_SRC}
     minc4itk/src/itkMincTransformIO.cxx
     minc4itk/src/itkMincTransformIOFactory.cxx
  )
  
  SET(ITKIOMINC_HEADER
    ${ITKIOMINC_HEADER}
    minc4itk/include/itkMincImageIOFactory.h
  )
ENDIF(ITK_VERSION_MAJOR VERSION_EQUAL 4)

INCLUDE_DIRECTORIES(${MINC2_INCLUDE_DIRS} minc4itk/include )
LINK_DIRECTORIES(${MINC2_LIBRARY_DIRS})

ADD_LIBRARY(ITKIOMINC ${ITKIOMINC_SRC} ${ITKIOMINC_HEADER})

TARGET_LINK_LIBRARIES(ITKIOMINC
  minc_io
  ${ITK_LIBRARIES}
  itkvnl_algo 
  itkvnl 
  volume_io2
  minc2
  m 
  z  )

INSTALL(FILES ${ITKIOMINC_HEADER}
   DESTINATION include)

INSTALL(TARGETS ITKIOMINC  ${LIBRARY_INSTALL} 
   DESTINATION lib)

ADD_EXECUTABLE(itk_convert  minc4itk/tools/itk_convert.cpp)
TARGET_LINK_LIBRARIES(itk_convert ITKIOMINC ${VOLUME_IO_LIBRARY} )

ADD_EXECUTABLE(itk_resample minc4itk/tools/itk_resample.cpp)
TARGET_LINK_LIBRARIES(itk_resample ITKIOMINC ${VOLUME_IO_LIBRARY} )

INSTALL(
  TARGETS
    itk_resample
    itk_convert
  DESTINATION 
    bin )

SET(MINC4ITK_LIBRARY ITKIOMINC)
