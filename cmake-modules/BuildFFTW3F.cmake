macro(build_fftw3f install_prefix staging_prefix)

  SET(FFTW3F_CONFIG --enable-sse --enable-sse2  --with-pic --disable-shared --enable-threads --disable-fortran --enable-single --enable-float)
  
  IF(NOT APPLE)
    LIST(APPEND FFTW3F_CONFIG --enable-avx )
  ENDIF(NOT APPLE)

  IF(MT_USE_OPENMP)
    LIST(APPEND FFTW3F_CONFIG --enable-openmp  )
  ENDIF(MT_USE_OPENMP)
  
  ExternalProject_Add(FFTW3F
        SOURCE_DIR FFTW3F
        URL "http://www.fftw.org/fftw-3.3.3.tar.gz"
        URL_MD5 "0a05ca9c7b3bfddc8278e7c40791a1c2"
        BUILD_IN_SOURCE 1
        INSTALL_DIR     "${staging_prefix}"
        BUILD_COMMAND   make
        INSTALL_COMMAND make DESTDIR=${staging_prefix} install
        CONFIGURE_COMMAND  ./configure ${FFTW3F_CONFIG}  --prefix=${install_prefix} CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} CFLAGS=${CMAKE_C_FLAGS} LDFLAGS=${CMAKE_MODULE_LINKER_FLAGS} CXXFLAGS=${CMAKE_CXX_FLAGS} 
#        INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/external
      )

SET(FFTW3F_INCLUDE_DIR ${staging_prefix}/${install_prefix}/include )
SET(FFTW3F_LIBRARY  ${staging_prefix}/${install_prefix}/lib/libfftw3f.a )
SET(FFTW3F_FOUND ON)


endmacro(build_fftw3f)
