macro(build_PatchMorphology install_prefix staging_prefix itk_dir)
  if(CMAKE_EXTRA_GENERATOR)
    set(CMAKE_GEN "${CMAKE_EXTRA_GENERATOR} - ${CMAKE_GENERATOR}")
  else()
    set(CMAKE_GEN "${CMAKE_GENERATOR}")
  endif()
  blas_external_project_args(BLAS_EP_ARGS)
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
        -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
        -DBUILD_TESTING:BOOL=${BUILD_TESTING}
        -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}
        -DCMAKE_SKIP_RPATH:BOOL=OFF
        -DCMAKE_SKIP_INSTALL_RPATH:BOOL=OFF
        -DMACOSX_RPATH:BOOL=ON
        -DCMAKE_INSTALL_RPATH:STRING=${MT_RPATH_ORIGIN}/../lib${LIB_SUFFIX}
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
      -DCMAKE_OSX_ARCHITECTURES:STRING=${CMAKE_OSX_ARCHITECTURES_EXTSEP}
      -DCMAKE_OSX_SYSROOT:STRING=${CMAKE_OSX_SYSROOT}
      -DCMAKE_OSX_DEPLOYMENT_TARGET:STRING=${CMAKE_OSX_DEPLOYMENT_TARGET}
#      -DCMAKE_C_COMPILER:FILEPATH=${ITK_C_COMPILER}
#      -DCMAKE_CXX_COMPILER:FILEPATH=${ITK_CXX_COMPILER}
    )
  endif()

  ExternalProject_Add(patch_morphology
    SOURCE_DIR ${CMAKE_SOURCE_DIR}/patch_morphology
    BINARY_DIR patch_morphology-build
    LIST_SEPARATOR :::  
    CMAKE_GENERATOR ${CMAKE_GEN}
    CMAKE_ARGS
#        -DLIBLBFGS_DIR:PATH=${LIBLBFGS_LIBRARY_DIR}
        -DMINC_TOOLKIT_BUILD:BOOL=ON
        -DSUPERBUILD_CMAKE_DIR:PATH=${PROJECT_SOURCE_DIR}/cmake-modules
        ${BLAS_EP_ARGS}
        -DITK_DIR:PATH=${itk_dir}
        -DPATCH_MORPHOLOGY_BUILD_LEGACY:BOOL=ON
        -DLIBMINC_DIR:PATH=${CMAKE_BINARY_DIR}/libminc
        ${CMAKE_EXTERNAL_PROJECT_ARGS}
    CMAKE_CACHE_ARGS
        -DMINC_TEST_ENVIRONMENT:STRING=${MINC_TEST_ENVIRONMENT}
    INSTALL_COMMAND $(MAKE) install DESTDIR=${staging_prefix}
    INSTALL_DIR ${staging_prefix}/${install_prefix}
    TEST_BEFORE_INSTALL 0 #TODO: figure out how to run test on external project
  )
  
  IF(BUILD_TESTING)
    ADD_TEST(NAME TEST_PATCH_MORPHOLOGY COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/patch_morphology-build 
    )

    IF(MINC_TEST_ENVIRONMENT)
        message("TEST_PATCH_MORPHOLOGY env: ${MINC_TEST_ENVIRONMENT}")
        set_tests_properties( TEST_PATCH_MORPHOLOGY PROPERTIES ENVIRONMENT "${MINC_TEST_ENVIRONMENT}")
    ENDIF()

  ENDIF(BUILD_TESTING)

endmacro(build_PatchMorphology)
