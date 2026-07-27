macro(build_EZMINC install_prefix staging_prefix libminc_dir bicpl_dir itk_dir)
  if(CMAKE_EXTRA_GENERATOR)
    set(CMAKE_GEN "${CMAKE_EXTRA_GENERATOR} - ${CMAKE_GENERATOR}")
  else()
    set(CMAKE_GEN "${CMAKE_GENERATOR}")
  endif()
  
  set(CMAKE_EXTERNAL_PROJECT_ARGS
        -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
        -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
        -DCMAKE_LINKER:FILEPATH=${CMAKE_LINKER}
        -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
        -DCMAKE_CXX_FLAGS_DEBUG:STRING=${CMAKE_CXX_FLAGS_DEBUG}
        -DCMAKE_CXX_FLAGS_MINSIZEREL:STRING=${CMAKE_CXX_FLAGS_MINSIZEREL}
        -DCMAKE_CXX_FLAGS_RELEASE:STRING=${CMAKE_CXX_FLAGS_RELEASE}
        -DCMAKE_CXX_FLAGS_RELWITHDEBINFO:STRING=${CMAKE_CXX_FLAGS_RELWITHDEBINFO}
        -DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS}
        -DCMAKE_C_FLAGS_DEBUG:STRING=${CMAKE_C_FLAGS_DEBUG}
        -DCMAKE_C_FLAGS_MINSIZEREL:STRING=${CMAKE_C_FLAGS_MINSIZEREL}
        -DCMAKE_C_FLAGS_RELEASE:STRING=${CMAKE_C_FLAGS_RELEASE}
        -DCMAKE_C_FLAGS_RELWITHDEBINFO:STRING=${CMAKE_C_FLAGS_RELWITHDEBINFO}
        -DCMAKE_EXE_LINKER_FLAGS:STRING=${CMAKE_EXE_LINKER_FLAGS}
        -DCMAKE_EXE_LINKER_FLAGS_DEBUG:STRING=${CMAKE_EXE_LINKER_FLAGS_DEBUG}
        -DCMAKE_EXE_LINKER_FLAGS_MINSIZEREL:STRING=${CMAKE_EXE_LINKER_FLAGS_MINSIZEREL}
        -DCMAKE_EXE_LINKER_FLAGS_RELEASE:STRING=${CMAKE_EXE_LINKER_FLAGS_RELEASE}
        -DCMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO:STRING=${CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO}
        -DCMAKE_MODULE_LINKER_FLAGS:STRING=${CMAKE_MODULE_LINKER_FLAGS}
        -DCMAKE_MODULE_LINKER_FLAGS_DEBUG:STRING=${CMAKE_MODULE_LINKER_FLAGS_DEBUG}
        -DCMAKE_MODULE_LINKER_FLAGS_MINSIZEREL:STRING=${CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL}
        -DCMAKE_MODULE_LINKER_FLAGS_RELEASE:STRING=${CMAKE_MODULE_LINKER_FLAGS_RELEASE}
        -DCMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO:STRING=${CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO}
        -DCMAKE_SHARED_LINKER_FLAGS:STRING=${CMAKE_SHARED_LINKER_FLAGS}
        -DCMAKE_SHARED_LINKER_FLAGS_DEBUG:STRING=${CMAKE_SHARED_LINKER_FLAGS_DEBUG}
        -DCMAKE_SHARED_LINKER_FLAGS_MINSIZEREL:STRING=${CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL}
        -DCMAKE_SHARED_LINKER_FLAGS_RELEASE:STRING=${CMAKE_SHARED_LINKER_FLAGS_RELEASE}
        -DCMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO:STRING=${CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO}
        -DCMAKE_STATIC_LINKER_FLAGS:STRING=${CMAKE_STATIC_LINKER_FLAGS}
        -DCMAKE_STATIC_LINKER_FLAGS_DEBUG:STRING=${CMAKE_STATIC_LINKER_FLAGS_DEBUG}
        -DCMAKE_STATIC_LINKER_FLAGS_MINSIZEREL:STRING=${CMAKE_STATIC_LINKER_FLAGS_MINSIZEREL}
        -DCMAKE_STATIC_LINKER_FLAGS_RELEASE:STRING=${CMAKE_STATIC_LINKER_FLAGS_RELEASE}
        -DCMAKE_STATIC_LINKER_FLAGS_RELWITHDEBINFO:STRING=${CMAKE_STATIC_LINKER_FLAGS_RELWITHDEBINFO}
        -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
        -DNETCDF_INCLUDE_DIR:PATH=${NETCDF_INCLUDE_DIR}            
        -DHDF5_C_INCLUDE_DIR:PATH=${HDF5_INCLUDE_DIR}
        -DHDF5_CPP_INCLUDE_DIR:PATH=${HDF5_INCLUDE_DIR}           
        -DHDF5_INCLUDE_DIR:PATH=${HDF5_INCLUDE_DIR}
        -DNETCDF_LIBRARY:STRING=${NETCDF_LIBRARY}
        -DHDF5_hdf5_LIBRARY:FILEPATH=${HDF5_LIBRARY}
        -DHDF5_hdf5_cpp_LIBRARY:FILEPATH=${HDF5_CPP_LIBRARY}                                                                                                                            
        -DHDF5_hdf5_c_LIBRARY:FILEPATH=${HDF5_LIBRARY}                                                                                                                                  
        -DHDF5_hdf5_LIBRARY_RELEASE:FILEPATH=${HDF5_LIBRARY}                                                                                                                            
        -DHDF5_hdf5_cpp_LIBRARY_RELEASE:FILEPATH=${HDF5_CPP_LIBRARY}                                                                                                                    
        -DHDF5_hdf5_LIBRARY_DEBUG:FILEPATH=${HDF5_LIBRARY}                                                                                                                              
        -DHDF5_hdf5_cpp_LIBRARY_DEBUG:FILEPATH=${HDF5_CPP_LIBRARY}                                                                                                                      
        -DHDF5_LIBRARY:FILEPATH=${HDF5_LIBRARY}                                                                                                                                         
        -DHDF5_CPP_LIBRARY:FILEPATH=${HDF5_CPP_LIBRARY}                                                                                                                                 
        -DHDF5_C_LIBRARY:FILEPATH=${HDF5_LIBRARY}                                                                                                                                       
        -DHDF5_LIBRARY_RELEASE:FILEPATH=${HDF5_LIBRARY}                                                                                                                                 
        -DHDF5_CPP_LIBRARY_RELEASE:FILEPATH=${HDF5_CPP_LIBRARY}                                                                                                                         
        -DHDF5_LIBRARY_DEBUG:FILEPATH=${HDF5_LIBRARY}                                                                                                                                   
        -DHDF5_CPP_LIBRARY_DEBUG:FILEPATH=${HDF5_CPP_LIBRARY}                                                                                                                           
        -DHDF5_LIBRARIES:STRING=${HDF5_LIBRARIES}                                                                                                                                       
        -DHDF5_INCLUDE_DIRS:STRING=${HDF5_INCLUDE_DIRS}                 
        -DZLIB_LIBRARY:FILEPATH=${ZLIB_LIBRARY}
        -DZLIB_INCLUDE_DIR:PATH=${ZLIB_INCLUDE_DIR}
  )

  if(APPLE)
    list(APPEND CMAKE_EXTERNAL_PROJECT_ARGS
      -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES_EXTSEP}
      -DCMAKE_OSX_SYSROOT=${CMAKE_OSX_SYSROOT}
      -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}
    )
  endif()

  
  
  ExternalProject_Add(EZMINC
    SOURCE_DIR ${CMAKE_SOURCE_DIR}/EZminc
    BINARY_DIR EZMINC-build
    LIST_SEPARATOR :::
    CMAKE_GENERATOR ${CMAKE_GEN}
    CMAKE_ARGS
        -DFFTW3F_FOUND:BOOL=${FFTW3F_FOUND}
        -DFFTW3F_INCLUDE_DIR:PATH=${FFTW3F_INCLUDE_DIR}
        -DFFTW3F_LIBRARY:PATH=${FFTW3F_LIBRARY}
        -DFFTW_LIB:FILEPATH=${FFTW3F_LIBRARY}
        -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
        -DLIBMINC_DIR:PATH=${libminc_dir}
        -DITK_DIR:PATH=${itk_dir}
        -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}
        -DEZMINC_BUILD_MINCNLM:BOOL=ON
        -DEZMINC_BUILD_DISTORTION_CORRECTION:BOOL=ON
        -DEZMINC_BUILD_MRFSEG:BOOL=ON
        -DEZMINC_BUILD_DD:BOOL=ON
        -DEZMINC_BUILD_TOOLS:BOOL=ON
        -DCMAKE_EXE_LINKER_FLAGS:STRING=${CMAKE_EXE_LINKER_FLAGS}
        -DCMAKE_MODULE_LINKER_FLAGS:STRING=${CMAKE_MODULE_LINKER_FLAGS}
        -DCMAKE_SHARED_LINKER_FLAGS:STRING=${CMAKE_SHARED_LINKER_FLAGS}
        -DBICPL_DIR:PATH=${bicpl_dir}
        -DGSL_CBLAS_LIBRARY:FILEPATH=${GSL_CBLAS_LIBRARY}
        -DGSL_INCLUDE_DIR:PATH=${GSL_INCLUDE_DIR}
        -DGSL_LIBRARY:FILEPATH=${GSL_LIBRARY}
        -DCMAKE_SKIP_RPATH:BOOL=OFF
        -DCMAKE_SKIP_INSTALL_RPATH:BOOL=OFF
        -DMACOSX_RPATH:BOOL=ON
        -DCMAKE_INSTALL_RPATH:PATH=${install_prefix}/lib${LIB_SUFFIX}
        ${CMAKE_EXTERNAL_PROJECT_ARGS}
    INSTALL_COMMAND $(MAKE) install DESTDIR=${staging_prefix}
    INSTALL_DIR ${staging_prefix}/${install_prefix}
  )
endmacro(build_EZMINC)
