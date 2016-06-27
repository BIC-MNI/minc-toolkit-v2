macro(build_freeglut install_prefix staging_prefix)

  IF(CMAKE_BUILD_TYPE STREQUAL Release)
    SET(EXT_C_FLAGS   "${CMAKE_C_FLAGS}   ${CMAKE_C_FLAGS_RELEASE}")
    SET(EXT_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}")
  ELSE()
    SET(EXT_C_FLAGS   "${CMAKE_C_FLAGS}    ${CMAKE_C_FLAGS_DEBUG}")
    SET(EXT_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}")
  ENDIF()

  find_library( GLUT_Xi_LIBRARY Xi
    /usr/openwin/lib
  )

  find_library( GLUT_Xmu_LIBRARY Xmu
    /usr/openwin/lib
  )

  find_library( GLUT_X11_LIBRARY X11
    /usr/openwin/lib
  )

ExternalProject_Add(FREEGLUT 
  SOURCE_DIR FREEGLUT
  URL "http://downloads.sourceforge.net/project/freeglut/freeglut/2.6.0/freeglut-2.6.0.tar.gz"
  URL_MD5 "39f0f2de89f399529d2b981188082218"
  BUILD_IN_SOURCE 1
  INSTALL_DIR     "${staging_prefix}"
  BUILD_COMMAND   $(MAKE)
  INSTALL_COMMAND $(MAKE) DESTDIR=${staging_prefix} install 
  CONFIGURE_COMMAND ./configure --prefix=${install_prefix} --with-pic --disable-shared --libdir=${install_prefix}/lib${LIB_SUFFIX} CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} "CXXFLAGS=${EXT_CXX_FLAGS}" "CFLAGS=${EXT_C_FLAGS}"
)

SET(GLUT_LIBRARY     ${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX}/libglut.a )
SET(GLUT_LIBRARIES   ${GLUT_LIBRARY} ${GLUT_Xmu_LIBRARY}  ${GLUT_Xi_LIBRARY} ${GLUT_X11_LIBRARY} )
SET(GLUT_INCLUDE_DIR ${staging_prefix}/${install_prefix}/include )
SET(GLUT_FOUND ON)

endmacro(build_freeglut)
