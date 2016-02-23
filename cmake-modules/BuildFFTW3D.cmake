macro(build_fftw3d install_prefix staging_prefix)
  
  IF(CMAKE_BUILD_TYPE STREQUAL Release)
    SET(EXT_C_FLAGS   "${CMAKE_C_FLAGS}   ${CMAKE_C_FLAGS_RELEASE}")
    SET(EXT_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}")
  ELSE()
    SET(EXT_C_FLAGS   "${CMAKE_C_FLAGS}    ${CMAKE_C_FLAGS_DEBUG}")
    SET(EXT_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}")
  ENDIF()

  SET(FFTW3D_CONFIG  --with-pic --disable-shared --enable-threads --disable-fortran )
  
  IF(NOT APPLE)
    LIST(APPEND FFTW3D_CONFIG --enable-avx )
  ENDIF(NOT APPLE)

  IF(MT_USE_OPENMP)
    LIST(APPEND FFTW3D_CONFIG --enable-openmp  )
  ENDIF(MT_USE_OPENMP)
  
  ExternalProject_Add(FFTW3D
        SOURCE_DIR FFTW3D
        URL "http://www.fftw.org/fftw-3.3.4.tar.gz"
        URL_MD5 "2edab8c06b24feeb3b82bbb3ebf3e7b3"
        BUILD_IN_SOURCE 1
        INSTALL_DIR     "${staging_prefix}"
        BUILD_COMMAND   $(MAKE)
        INSTALL_COMMAND $(MAKE) DESTDIR=${staging_prefix} install
        CONFIGURE_COMMAND  ./configure ${FFTW3D_CONFIG} --libdir=${install_prefix}/lib${LIB_SUFFIX} --prefix=${install_prefix} CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} "CXXFLAGS=${EXT_CXX_FLAGS}" "CFLAGS=${EXT_C_FLAGS}"
#        INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/external
      )

SET(FFTW3D_INCLUDE_DIR ${staging_prefix}/${install_prefix}/include )
SET(FFTW3D_LIBRARY  ${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX}/libfftw3.a )
SET(FFTW3D_THREADS_LIBRARY  ${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX}/libfftw3_threads.a )
SET(FFTW3D_FOUND ON)


endmacro(build_fftw3d)
