macro(build_PatchMorphology install_prefix staging_prefix itk_dir)
  if(CMAKE_EXTRA_GENERATOR)
    set(CMAKE_GEN "${CMAKE_EXTRA_GENERATOR} - ${CMAKE_GENERATOR}")
  else()
    set(CMAKE_GEN "${CMAKE_GENERATOR}")
  endif()

  message("CMAKE_EXTERNAL_PROJECT_ARGS_FOR_ITK5=${CMAKE_EXTERNAL_PROJECT_ARGS_FOR_ITK5}")
  set(CMAKE_EXTERNAL_PROJECT_ARGS ${CMAKE_EXTERNAL_PROJECT_ARGS_FOR_ITK5})

  blas_external_project_args(BLAS_EP_ARGS)

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
        -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}
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
