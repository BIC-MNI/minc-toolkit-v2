macro(build_ANTS install_prefix staging_prefix itk_dir ) #boost_dir
  if(CMAKE_EXTRA_GENERATOR)
    set(CMAKE_GEN "${CMAKE_EXTRA_GENERATOR} - ${CMAKE_GENERATOR}")
  else()
    set(CMAKE_GEN "${CMAKE_GENERATOR}")
  endif()
  
  ExternalProject_Add(ANTS
    #GIT_REPOSITORY "https://github.com/vfonov/ANTs.git"
    #GIT_TAG "69d3a5a6c7125ccf07a9e9cf6ef29f0b91e9514f"
    #UPDATE_COMMAND ""
    SOURCE_DIR ${CMAKE_SOURCE_DIR}/ANTs
    BINARY_DIR ANTS-build
    LIST_SEPARATOR :::  
    CMAKE_GENERATOR ${CMAKE_GEN}
    CMAKE_ARGS
        -DITK_DIR:PATH=${itk_dir}
        -DITK_USE_FFTWD:BOOL=OFF # V.F. not sure how to make it work
        -DITK_USE_FFTWF:BOOL=OFF # V.F. not sure how to make it work
        -DITK_USE_SYSTEM_FFTW:BOOL=OFF # V.F. not sure how to make it work
        -DANTS_SUPERBUILD:BOOL=OFF
        -DBUILD_TESTING:BOOL=OFF
        -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}
        -DCMAKE_SKIP_RPATH:BOOL=OFF
        -DCMAKE_SKIP_INSTALL_RPATH:BOOL=OFF
        -DMACOSX_RPATH:BOOL=ON
        -DITK_USE_FFTWD:BOOL=ON
        -DITK_USE_FFTWF:BOOL=ON
        -DITK_USE_SYSTEM_FFTW:BOOL=ON
        -DCMAKE_INSTALL_RPATH:PATH=${install_prefix}/lib${LIB_SUFFIX}
        ${CMAKE_EXTERNAL_PROJECT_ARGS_FOR_ITK5}
    INSTALL_COMMAND $(MAKE) install DESTDIR=${staging_prefix}
    INSTALL_DIR ${staging_prefix}/${install_prefix}
  )
endmacro(build_ANTS)
