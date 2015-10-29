macro(build_itkv4 install_prefix staging_prefix minc_dir hdf_bin_dir hdf_include_dir hdf_library_dir zlib_include_dir zlib_library)
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
      -DCMAKE_OSX_ARCHITECTURES:STRING=${CMAKE_OSX_ARCHITECTURES}
      -DCMAKE_OSX_SYSROOT:STRING=${CMAKE_OSX_SYSROOT}
      -DCMAKE_OSX_DEPLOYMENT_TARGET:STRING=${CMAKE_OSX_DEPLOYMENT_TARGET}
      -DCMAKE_C_COMPILER:FILEPATH=${ITK_C_COMPILER}
      -DCMAKE_CXX_COMPILER:FILEPATH=${ITK_CXX_COMPILER}
    )
  endif()
	
  SET(HDF5_LIB_SUFFIX ".a")
  
  IF(MT_BUILD_SHARED_LIBS) 
    SET(ITK_SHARED_LIBRARY "ON")
    
    IF(MT_BUILD_SHARED_LIBS)
      IF(APPLE)
        IF(${CMAKE_BUILD_TYPE} STREQUAL Release)
          SET(HDF5_LIB_SUFFIX ".dylib")
        ELSE(${CMAKE_BUILD_TYPE} STREQUAL Release)
          SET(HDF5_LIB_SUFFIX "_debug.dylib")
        ENDIF(${CMAKE_BUILD_TYPE} STREQUAL Release)
      ELSE(APPLE)
        IF(${CMAKE_BUILD_TYPE} STREQUAL Release)
          SET(HDF5_LIB_SUFFIX ".so")
        ELSE(${CMAKE_BUILD_TYPE} STREQUAL Release)
          SET(HDF5_LIB_SUFFIX "_debug.so")
        ENDIF(${CMAKE_BUILD_TYPE} STREQUAL Release)
      ENDIF(APPLE)
  ELSE(MT_BUILD_SHARED_LIBS)
    IF(${CMAKE_BUILD_TYPE} STREQUAL Release)
      SET(HDF5_LIB_SUFFIX ".a")
    ELSE(${CMAKE_BUILD_TYPE} STREQUAL Release)
      SET(HDF5_LIB_SUFFIX "_debug.a")
    ENDIF(${CMAKE_BUILD_TYPE} STREQUAL Release)
  ENDIF(MT_BUILD_SHARED_LIBS)
    
    
  else(MT_BUILD_SHARED_LIBS) 
    SET(ITK_SHARED_LIBRARY "OFF")
  endif(MT_BUILD_SHARED_LIBS) 

  ExternalProject_Add(ITKv4
    #GIT_REPOSITORY "http://itk.org/ITK.git"
    #GIT_TAG "421d314ff85ad542ad5c0f3d3c115fa7427b1c64"
    URL "http://downloads.sourceforge.net/project/itk/itk/4.8/InsightToolkit-4.8.0.tar.gz"
    URL_MD5 "2d62f628d9e96cc790fa37947a0f9bc3"
    PATCH_COMMAND patch -p 1 -d ${CMAKE_CURRENT_BINARY_DIR}/ITKv4 -u -i ${CMAKE_CURRENT_SOURCE_DIR}/cmake-modules/ITK-changes-since-release-4.8.patch 
    UPDATE_COMMAND ""
    SOURCE_DIR ITKv4
    BINARY_DIR ITKv4-build
    CMAKE_GENERATOR ${CMAKE_GEN}
    CMAKE_ARGS
        -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
        -DBUILD_SHARED_LIBS:BOOL=${ITK_SHARED_LIBRARY}
        -DCMAKE_SKIP_RPATH:BOOL=YES
        -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}
        "-DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}"
        "-DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS}"
        -DCMAKE_EXE_LINKER_FLAGS:STRING=${CMAKE_EXE_LINKER_FLAGS}
        -DCMAKE_MODULE_LINKER_FLAGS:STRING=${CMAKE_MODULE_LINKER_FLAGS}
        -DCMAKE_SHARED_LINKER_FLAGS:STRING=${CMAKE_SHARED_LINKER_FLAGS}
        ${CMAKE_OSX_EXTERNAL_PROJECT_ARGS}
        -DBUILD_EXAMPLES:BOOL=OFF
        -DBUILD_TESTING:BOOL=OFF
        -DITK_USE_REVIEW:BOOL=ON
        -DModule_ITKIOMINC:BOOL=ON
        -DModule_ITKIOTransformMINC:BOOL=ON
        -DITK_USE_SYSTEM_MINC:BOOL=ON
        -DITK_USE_SYSTEM_HDF5:BOOL=ON
        -DITK_USE_SYSTEM_ZLIB:BOOL=ON
        -DITK_USE_FFTWD:BOOL=ON
        -DITK_USE_FFTWF:BOOL=ON
        -DITK_USE_SYSTEM_FFTW:BOOL=ON
        -DFFTWD_LIB:FILEPATH=${FFTW3D_LIBRARY}
        -DFFTWD_THREADS_LIB:FILEPATH=${FFTW3D_THREADS_LIBRARY}
        -DFFTWF_LIB:FILEPATH=${FFTW3F_LIBRARY}
        -DFFTWF_THREADS_LIB:FILEPATH=${FFTW3F_THREADS_LIBRARY}
        -DFFTW_INCLUDE_PATH:PATH=${FFTW3D_INCLUDE_DIR}
        -DLIBMINC_DIR:PATH=${minc_dir}
        -DHDF5_CXX_COMPILER_EXECUTABLE:FILEPATH=${hdf_bin_dir}/h5c++
        -DHDF5_C_COMPILER_EXECUTABLE:FILEPATH=${hdf_bin_dir}/h5cc
        -DHDF5_CXX_LIBRARY:PATH=${hdf_library_dir}/libhdf5_cpp${HDF5_LIB_SUFFIX}
        -DHDF5_C_LIBRARY:PATH=${hdf_library_dir}/libhdf5${HDF5_LIB_SUFFIX}
        -DHDF5_DIFF_EXECUTABLE:FILEPATH=${hdf_bin_dir}/h5diff
        -DHDF5_CXX_INCLUDE_DIR:PATH=${hdf_include_dir}
        -DHDF5_C_INCLUDE_DIR:PATH=${hdf_include_dir}
        -DHDF5_hdf5_LIBRARY:FILEPATH=${hdf_library_dir}/libhdf5${HDF5_LIB_SUFFIX}
        -DHDF5_hdf5_cpp_LIBRARY:FILEPATH=${hdf_library_dir}/libhdf5_cpp${HDF5_LIB_SUFFIX}
        -DHDF5_hdf5_LIBRARY_RELEASE:FILEPATH=${hdf_library_dir}/libhdf5${HDF5_LIB_SUFFIX}
        -DHDF5_hdf5_cpp_LIBRARY_RELEASE:FILEPATH=${hdf_library_dir}/libhdf5_cpp${HDF5_LIB_SUFFIX}
#        -DHDF5_DIR:PATH=/home/vfonov/src/build/minc-toolkit-itk4/HDF5-build
        -DHDF5_Fortran_COMPILER_EXECUTABLE:FILEPATH=''
        -DZLIB_LIBRARY:PATH=${zlib_library}
        -DZLIB_INCLUDE_DIR:PATH=${zlib_include_dir}
        -DITK_LEGACY_REMOVE:BOOL=OFF
    INSTALL_COMMAND $(MAKE) install DESTDIR=${staging_prefix}
    INSTALL_DIR ${staging_prefix}/${install_prefix}
    STEP_TARGETS PatchInstall
  )
  
  ExternalProject_Add_Step(ITKv4 PatchInstall 
    COMMAND ${CMAKE_COMMAND} -Dstaging_prefix=${staging_prefix} -Dminc_dir=${minc_dir} -Dinstall_prefix=${install_prefix} -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake-modules/PatchITKv4.cmake
    COMMENT "Patching ITKv4 Build"
    DEPENDEES install
    )
  
  # let's patch targets to remove staging directory
  
  
  SET(ITK_DIR ${CMAKE_CURRENT_BINARY_DIR}/ITKv4-build)
  
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
          itksys itkjpeg8 itkjpeg12 itkjpeg16 itkopenjpeg  hdf5_cpp hdf5
          ${CMAKE_THREAD_LIBS_INIT}
          )

  IF(UNIX)
    SET(ITK_LIBRARIES  ${ITK_LIBRARIES} dl)
  ENDIF(UNIX)

endmacro(build_itkv4)
