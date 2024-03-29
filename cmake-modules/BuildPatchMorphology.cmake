macro(build_PatchMorphology install_prefix staging_prefix itk_dir)
  if(CMAKE_EXTRA_GENERATOR)
    set(CMAKE_GEN "${CMAKE_EXTRA_GENERATOR} - ${CMAKE_GENERATOR}")
  else()
    set(CMAKE_GEN "${CMAKE_GENERATOR}")
  endif()
  message("OpenBLAS_DIR=${OpenBLAS_DIR}")
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
        -DOpenBLAS_INCLUDE_DIRS:PATH=${OpenBLAS_INCLUDE_DIRS}
        -DOpenBLAS_LIBRARIES:PATH=${OpenBLAS_LIBRARIES}
        -DOpenBLAS_LIBRARY:PATH=${OpenBLAS_LIBRARY}
        -DCMAKE_DISABLE_FIND_PACKAGE_OpenBLAS:BOOL=ON
        -DOpenBLAS_DIR:PATH=${OpenBLAS_DIR}
        -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
        -DBUILD_TESTING:BOOL=${BUILD_TESTING}
        -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}
        -DCMAKE_SKIP_RPATH:BOOL=OFF
        -DCMAKE_SKIP_INSTALL_RPATH:BOOL=OFF
        -DMACOSX_RPATH:BOOL=ON
        -DCMAKE_INSTALL_RPATH:PATH=${install_prefix}/lib${LIB_SUFFIX}
  )
  if(APPLE)
    list(APPEND CMAKE_EXTERNAL_PROJECT_ARGS
      -DCMAKE_OSX_ARCHITECTURES:STRING=${CMAKE_OSX_ARCHITECTURES}
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
        -DOpenBLAS_DIR:PATH=${OpenBLAS_DIR}
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
