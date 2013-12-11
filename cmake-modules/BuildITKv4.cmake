macro(build_itkv4 install_prefix staging_prefix)
  find_package(Threads REQUIRED)

  if(CMAKE_EXTRA_GENERATOR)
    set(CMAKE_GEN "${CMAKE_EXTRA_GENERATOR} - ${CMAKE_GENERATOR}")
  else()
    set(CMAKE_GEN "${CMAKE_GENERATOR}")
  endif()
  
  set(CMAKE_OSX_EXTERNAL_PROJECT_ARGS)
  if(APPLE)
    SET(ITK_CXX_COMPILER "${CMAKE_CXX_COMPILER}" CACHE FILEPATH "C++ Compiler for ITK")
    SET(ITK_C_COMPILER "${CMAKE_C_COMPILER}" CACHE FILEPATH "C Compiler for ITK")
    list(APPEND CMAKE_OSX_EXTERNAL_PROJECT_ARGS
      -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES}
      -DCMAKE_OSX_SYSROOT=${CMAKE_OSX_SYSROOT}
      -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}
      -DCMAKE_C_COMPILER:FILEPATH=${ANTS_C_COMPILER}
      -DCMAKE_CXX_COMPILER:FILEPATH=${ANTS_CXX_COMPILER}
    )
  endif()
	
  if(MT_BUILD_SHARED_LIBS) 
    SET(ITK_SHARED_LIBRARY "ON")
  else(MT_BUILD_SHARED_LIBS) 
    SET(ITK_SHARED_LIBRARY "OFF")
  endif(MT_BUILD_SHARED_LIBS) 

  ExternalProject_Add(ITKv4
#    URL "http://downloads.sourceforge.net/project/itk/itk/3.20/InsightToolkit-3.20.1.tar.gz"
#    URL_MD5 "90342ffa78bd88ae48b3f62866fbf050"
    GIT_REPOSITORY "https://github.com/vfonov/ITK.git" #"http://itk.org/ITK.git"
    GIT_TAG "579bed244964119d8a9a65c1f45e91b5d654c4fa"
    UPDATE_COMMAND ""
    SOURCE_DIR ITKv4
    BINARY_DIR ITKv4-build
    CMAKE_GENERATOR ${CMAKE_GEN}
    CMAKE_ARGS
        -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
        -DBUILD_SHARED_LIBS:BOOL=${ITK_SHARED_LIBRARY}
        -DCMAKE_SKIP_RPATH:BOOL=YES
        -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}
        -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
        -DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS}
        -DCMAKE_EXE_LINKER_FLAGS=${CMAKE_EXE_LINKER_FLAGS}
        -DCMAKE_MODULE_LINKER_FLAGS=${CMAKE_MODULE_LINKER_FLAGS}
        -DCMAKE_SHARED_LINKER_FLAGS=${CMAKE_SHARED_LINKER_FLAGS}
        ${CMAKE_OSX_EXTERNAL_PROJECT_ARGS}
        -DBUILD_EXAMPLES:BOOL=OFF
        -DBUILD_TESTING:BOOL=OFF
        -DITK_USE_REVIEW:BOOL=ON
        -DITK_LEGACY_REMOVE:BOOL=OFF
    INSTALL_COMMAND make install DESTDIR=${staging_prefix}
    INSTALL_DIR ${staging_prefix}/${install_prefix}
  )
  #FORCE_BUILD_CHECK(ITKv4)
  SET(ITK_DIR ${CMAKE_CURRENT_BINARY_DIR}/ITKv4-build)
  SET(ITK_USE_FILE  ${CMAKE_CURRENT_BINARY_DIR}/ITKv4-build/UseITK.cmake)
  SET(ITK_FOUND ON)
  
  SET(ITK_INCLUDE_DIRS 
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4-build
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4/Code/Algorithms
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4/Code/BasicFilters
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4/Code/Common
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4/Code/Numerics
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4/Code/IO
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4/Code/Numerics/FEM
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4/Code/Numerics/NeuralNetworks
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4/Code/SpatialObject
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4/Utilities/MetaIO
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4/Utilities/NrrdIO
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4-build/Utilities/NrrdIO
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4/Utilities/DICOMParser
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4-build/Utilities/DICOMParser
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4-build/Utilities/expat
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4/Utilities/expat
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4/Utilities/nifti/niftilib
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4/Utilities/nifti/znzlib
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4/Utilities/itkExtHdrs
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4-build/Utilities
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4/Utilities
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4/Utilities/vxl/v3p/netlib
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4/Utilities/vxl/vcl
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4/Utilities/vxl/core
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4-build/Utilities/vxl/v3p/netlib
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4-build/Utilities/vxl/vcl
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4-build/Utilities/vxl/core
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4-build/Utilities/gdcm
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4/Utilities/gdcm/src
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4/Code/Review
        ${CMAKE_CURRENT_BINARY_DIR}/ITKv4/Code/Review/Statistics)

# The ITK library directories.
  SET(ITK_LIBRARY_DIRS "${CMAKE_CURRENT_BINARY_DIR}/ITKv4-build/bin")
  
  SET(ITK_LIBRARIES  
          ITKAlgorithms ITKStatistics 
          ITKNumerics 
          ITKFEM ITKQuadEdgeMesh 
          ITKBasicFilters  ITKIO ITKNrrdIO 
          ITKSpatialObject ITKMetaIO
          ITKDICOMParser ITKEXPAT
          ITKniftiio ITKTransformIOReview  ITKCommon ITKznz 
          itkgdcm itkpng itktiff itkzlib itkvcl 
          itkvcl 
          itkv3p_lsqr  itkvnl_algo itkvnl_inst itkvnl itkv3p_netlib 
          itksys itkjpeg8 itkjpeg12 itkjpeg16 itkopenjpeg
           ${CMAKE_THREAD_LIBS_INIT}
          )
	
	IF(UNIX)
		SET(ITK_LIBRARIES  ${ITK_LIBRARIES} dl)
	ENDIF(UNIX)
	
endmacro(build_itkv3)
