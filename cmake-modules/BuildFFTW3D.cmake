macro(build_fftw3d install_prefix staging_prefix)
  
  IF(CMAKE_BUILD_TYPE STREQUAL Release)
    SET(EXT_C_FLAGS   "${CMAKE_C_FLAGS}   ${CMAKE_C_FLAGS_RELEASE}")
    SET(EXT_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}")
  ELSE()
    SET(EXT_C_FLAGS   "${CMAKE_C_FLAGS}    ${CMAKE_C_FLAGS_DEBUG}")
    SET(EXT_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}")
  ENDIF()


  SET(EXT_C_COMPILER ${CMAKE_C_COMPILER})
  SET(EXT_CXX_COMPILER ${CMAKE_CXX_COMPILER})
  IF(CCACHE_FOUND)
    SET(EXT_C_COMPILER   "${CCACHE_FOUND} ${CMAKE_C_COMPILER}")
    SET(EXT_CXX_COMPILER "${CCACHE_FOUND} ${CMAKE_CXX_COMPILER}")
  ENDIF(CCACHE_FOUND)

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
        BUILD_COMMAND   $(MAKE) -s V=0
        INSTALL_COMMAND $(MAKE) -s V=0 DESTDIR=${staging_prefix} install
        CONFIGURE_COMMAND  ./configure --enable-silent-rules --silent ${FFTW3D_CONFIG} --libdir=${install_prefix}/lib${LIB_SUFFIX} --prefix=${install_prefix} "CC=${EXT_C_COMPILER}" "CXX=${EXT_CXX_COMPILER}" "CXXFLAGS=${EXT_CXX_FLAGS}" "CFLAGS=${EXT_C_FLAGS}"
#        INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/external
      )

      
SET(FFTW3D_INCLUDE_DIR      ${install_prefix}/include )
SET(FFTW3D_LIBRARY          ${install_prefix}/lib${LIB_SUFFIX}/libfftw3.a )
SET(FFTW3D_THREADS_LIBRARY  ${install_prefix}/lib${LIB_SUFFIX}/libfftw3_threads.a )
SET(FFTW3D_OMP_LIBRARY      ${install_prefix}/lib${LIB_SUFFIX}/libfftw3_omp.a )
configure_file(${CMAKE_SOURCE_DIR}/cmake-modules/FFTW3DConfig.cmake.in ${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX}/FFTW3DConfig.cmake @ONLY)

SET(FFTW3D_INCLUDE_DIR ${staging_prefix}/${install_prefix}/include )
SET(FFTW3D_LIBRARY  ${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX}/libfftw3.a )
SET(FFTW3D_THREADS_LIBRARY  ${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX}/libfftw3_threads.a )
SET(FFTW3D_OMP_LIBRARY  ${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX}/libfftw3_omp.a )
SET(FFTW3D_FOUND ON)

endmacro(build_fftw3d)
