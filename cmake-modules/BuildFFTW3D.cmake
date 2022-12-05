macro(build_fftw3d install_prefix staging_prefix)
  
  SET(EXT_CONFIG_ARGS --enable-silent-rules --silent --enable-threads --disable-fortran --with-pic --disable-shared --enable-static --disable-doc )

  IF(CMAKE_BUILD_TYPE STREQUAL Release)
    SET(EXT_C_FLAGS   "${CMAKE_C_FLAGS}   ${CMAKE_C_FLAGS_RELEASE}")
    SET(EXT_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}")
    SET(EXT_LDFLAGS   "-L${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX} ${CMAKE_MODULE_LINKER_FLAGS} ${CMAKE_MODULE_LINKER_FLAGS_RELEASE} ")
    SET(EXT_CONFIG_ARGS ${EXT_CONFIG_ARGS} --disable-debug)
  ELSE()
    SET(EXT_C_FLAGS   "${CMAKE_C_FLAGS}    ${CMAKE_C_FLAGS_DEBUG}")
    SET(EXT_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}")
    SET(EXT_LDFLAGS   "-L${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX} ${CMAKE_MODULE_LINKER_FLAGS} ${CMAKE_MODULE_LINKER_FLAGS_DEBUG}" )
    SET(EXT_CONFIG_ARGS ${EXT_CONFIG_ARGS} --enable-debug)
  ENDIF()

  if(APPLE)
    SET(EXT_C_FLAGS     "${EXT_C_FLAGS} -isysroot ${CMAKE_OSX_SYSROOT}")
    SET(EXT_CXX_FLAGS   "${EXT_CXX_FLAGS} -isysroot ${CMAKE_OSX_SYSROOT}")
    if(MT_APPLE_ARCH STREQUAL "arm64")
      #SET(EXT_CONFIG_ARGS ${EXT_CONFIG_ARGS} --enable-neon)
    endif()
  else()
    SET(EXT_CONFIG_ARGS ${EXT_CONFIG_ARGS} --enable-sse --enable-sse2)
  endif()

  IF(MT_USE_OPENMP)
    SET(EXT_CONFIG_ARGS ${EXT_CONFIG_ARGS} --enable-openmp)
  ELSE()
    SET(EXT_CONFIG_ARGS ${EXT_CONFIG_ARGS} --disable-openmp)
  ENDIF(MT_USE_OPENMP)

#  --host=${MACHINE_NAME}

  GET_PACKAGE("https://www.fftw.org/fftw-3.3.10.tar.gz" "8ccbf6a5ea78a16dbc3e1306e234cc5c" "fftw-3.3.10.tar.gz" FFTW_PATH )

    ExternalProject_Add(FFTW3D
      SOURCE_DIR FFTW3D
      URL  "${FFTW_PATH}"
      URL_MD5 "8ccbf6a5ea78a16dbc3e1306e234cc5c"
      BUILD_IN_SOURCE 1
      INSTALL_DIR     "${CMAKE_BINARY_DIR}/external"
      BUILD_COMMAND   $(MAKE) -s V=0 
      INSTALL_COMMAND $(MAKE) -s V=0 DESTDIR=${CMAKE_BINARY_DIR}/external install
      CONFIGURE_COMMAND  ./configure  
        ${EXT_CONFIG_ARGS}
        --prefix=${install_prefix} 
        --libdir=${install_prefix}/lib${LIB_SUFFIX}
          CXX=${CMAKE_CXX_COMPILER}
          CC=${CMAKE_C_COMPILER}
          AR=${CMAKE_C_COMPILER_AR}
          RANLIB=${CMAKE_C_COMPILER_RANLIB}
          NM=${CMAKE_NM}
          STRIP=${CMAKE_STRIP}
          CXXFLAGS=${EXT_CXX_FLAGS}
          CFLAGS=${EXT_C_FLAGS}
          LDFLAGS=${EXT_LDFLAGS}
    )


      
SET(FFTW3_INCLUDE_DIR      ${install_prefix}/include )
SET(FFTW3_LIBRARY          ${install_prefix}/lib${LIB_SUFFIX}/libfftw3.a )
SET(FFTW3_THREADS_LIBRARY  ${install_prefix}/lib${LIB_SUFFIX}/libfftw3_threads.a )
SET(FFTW3_OMP_LIBRARY      ${install_prefix}/lib${LIB_SUFFIX}/libfftw3_omp.a )
#configure_file(${CMAKE_SOURCE_DIR}/cmake-modules/FFTW3DConfig.cmake.in ${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX}/FFTW3DConfig.cmake @ONLY)

      
SET(FFTW3_INCLUDE_DIR      ${staging_prefix}/${install_prefix}/include )
SET(FFTW3_LIBRARY          ${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX}/libfftw3.a )
SET(FFTW3_THREADS_LIBRARY  ${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX}/libfftw3_threads.a )
SET(FFTW3_OMP_LIBRARY      ${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX}/libfftw3_omp.a )


SET(FFTW3_FOUND ON)


endmacro(build_fftw3d)
