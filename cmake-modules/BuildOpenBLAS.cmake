macro(build_open_blas install_prefix staging_prefix parallel)

  set_property(DIRECTORY PROPERTY EP_STEP_TARGETS configure build test)

  SET(EXT_CMAKE_CXX_FLAGS_RELEASE ${CMAKE_CXX_FLAGS_RELEASE})
  SET(EXT_CMAKE_C_FLAGS_RELEASE   ${CMAKE_C_FLAGS_RELEASE})
  
  SET(EXT_CMAKE_CXX_FLAGS_DEBUG   ${CMAKE_CXX_FLAGS_DEBUG})
  SET(EXT_CMAKE_C_FLAGS_DEBUG     ${CMAKE_C_FLAGS_DEBUG})
  
  SET(EXT_CMAKE_CXX_FLAGS "-fPIC ${CMAKE_CXX_FLAGS}")
  SET(EXT_CMAKE_C_FLAGS   "-fPIC ${CMAKE_C_FLAGS}")
  
  if(NOT CMAKE_Fortran_COMPILER)
    message("Fortran compiler not found! OpenBLAS will not work as expected!")
  endif(NOT CMAKE_Fortran_COMPILER)
  
  SET(BLAS_PARALLEL "NO_AFFINITY=1 USE_THREAD=0 USE_OPENMP=0")
  if(parallel)
    SET(BLAS_PARALLEL "NO_AFFINITY=1 USE_OPENMP=1")
  endif(parallel)
  
  ExternalProject_Add(OpenBLAS
        URL "http://github.com/xianyi/OpenBLAS/archive/v0.2.18.tar.gz"
        URL_MD5 "805e7f660877d588ea7e3792cda2ee65"
        SOURCE_DIR OpenBLAS
        BUILD_IN_SOURCE 1
        #BINARY_DIR OpenBLAS-build
        INSTALL_DIR       "${CMAKE_BINARY_DIR}/external"
        BUILD_COMMAND      $(MAKE) PREFIX=${install_prefix} USE_THREAD=0 USE_OPENMP=0 CC=${CMAKE_C_COMPILER} FC=${CMAKE_Fortran_COMPILER} MAKE_NB_JOBS=1
        CONFIGURE_COMMAND  $(MAKE) PREFIX=${install_prefix} USE_THREAD=0 USE_OPENMP=0 CC=${CMAKE_C_COMPILER} FC=${CMAKE_Fortran_COMPILER} MAKE_NB_JOBS=1
        INSTALL_COMMAND    $(MAKE) DESTDIR=${CMAKE_BINARY_DIR}/external install PREFIX=${install_prefix}
      )
  
  # a hack to find full path to gfortran library
  
  #find_library( GFORTRAN_LIBRARY NAMES gfortran )
  SET(OpenBLAS_INCLUDE_DIRS ${staging_prefix}/${install_prefix}/include )
  SET(OpenBLAS_LIBRARY    ${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX}/libopenblas.so  ) # ${GFORTRAN_LIBRARY}
  SET(OpenBLAS_FOUND ON)

endmacro(build_open_blas)
  