macro(build_Elastix install_prefix staging_prefix)
  if(CMAKE_EXTRA_GENERATOR)
    set(CMAKE_GEN "${CMAKE_EXTRA_GENERATOR} - ${CMAKE_GENERATOR}")
  else()
    set(CMAKE_GEN "${CMAKE_GENERATOR}")
  endif()
  

  ExternalProject_Add(Elastix
    SOURCE_DIR ${CMAKE_SOURCE_DIR}/Elastix
    BINARY_DIR Elastix-build
    LIST_SEPARATOR :::  
    CMAKE_GENERATOR ${CMAKE_GEN}
    CMAKE_ARGS
        -DFFTW3F_FOUND:BOOL=${FFTW3F_FOUND}
        -DFFTW3F_INCLUDE_DIR:PATH=${FFTW3F_INCLUDE_DIR}
        -DFFTW3F_LIBRARY:PATH=${FFTW3F_LIBRARY}
        -DELASTIX_BUILD_EXECUTABLE:BOOL=ON
        -DUSE_KNNGraphAlphaMutualInformationMetric:BOOL=ON
        -DUSE_SimilarityTransformElastix:BOOL=ON
        -DUSE_GradientDifferenceMetric:BOOL=ON
        -DUSE_FixedShrinkingPyramid:BOOL=ON
        -DUSE_BSplineResampleInterpolatorFloat:BOOL=ON
        -DUSE_BSplineInterpolatorFloat:BOOL=ON
        -DUSE_WeightedCombinationTransformElastix:BOOL=ON
        -DUSE_MovingShrinkingPyramid:BOOL=ON
        -DUSE_DisplacementMagnitudePenalty:BOOL=ON
        -DUSE_NormalizedGradientCorrelationMetric:BOOL=ON
        -DUSE_CMAEvolutionStrategy:BOOL=ON
        -DUSE_MissingStructurePenalty:BOOL=OFF
        -DUSE_AffineLogTransformElastix:BOOL=ON
        -DUSE_LinearResampleInterpolator:BOOL=ON
        -DUSE_MutualInformationHistogramMetric:BOOL=ON
        -DUSE_NearestNeighborInterpolator:BOOL=ON
        -DUSE_NearestNeighborResampleInterpolator:BOOL=ON
        -DUSE_Simplex:BOOL=ON
        -DUSE_ViolaWellsMutualInformationMetric:BOOL=ON
        -DUSE_AdaptiveStochasticLBFGS:BOOL=OFF  # HACKING FOR ITKv5
        -DUSE_AdaptiveStochasticVarianceReducedGradient:BOOL=OFF
        -DUSE_PreconditionedStochasticGradientDescent:BOOL=OFF
        -DUSE_MultiMetricMultiResolutionRegistration:BOOL=OFF
        -DUSE_MultiResolutionRegistrationWithFeatures:BOOL=OFF
        -DUSE_AffineLogTransformElastix:BOOL=OFF
        -DUSE_SimilarityTransformElastix:BOOL=OFF
        -DUSE_WeightedCombinationTransformElastix:BOOL=OFF
        -DFFTW_LIB:FILEPATH=${FFTW3F_LIBRARY}
        -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
        -DITK_DIR:PATH=${ITK_DIR}
        -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}
        -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
        -DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS}
        -DCMAKE_EXE_LINKER_FLAGS=${CMAKE_EXE_LINKER_FLAGS}
        -DCMAKE_MODULE_LINKER_FLAGS=${CMAKE_MODULE_LINKER_FLAGS}
        -DCMAKE_SHARED_LINKER_FLAGS=${CMAKE_SHARED_LINKER_FLAGS}
        -DELASTIX_HELP_DIR:PATH=${CMAKE_CURRENT_BINARY_DIR}/Elastix-build/help
        -DCMAKE_SKIP_RPATH:BOOL=OFF
        -DCMAKE_SKIP_INSTALL_RPATH:BOOL=OFF
        -DMACOSX_RPATH:BOOL=ON
        -DCMAKE_INSTALL_RPATH:PATH=${install_prefix}/lib${LIB_SUFFIX}
        ${CMAKE_EXTERNAL_PROJECT_ARGS_FOR_ITK5}
    INSTALL_COMMAND $(MAKE) install DESTDIR=${staging_prefix}
    INSTALL_DIR ${staging_prefix}/${install_prefix}
  )
endmacro(build_Elastix)
