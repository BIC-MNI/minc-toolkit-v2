macro(build_itkv4 install_prefix staging_prefix minc_dir)
  find_package(Threads REQUIRED)

  if(CMAKE_EXTRA_GENERATOR)
    set(CMAKE_GEN "${CMAKE_EXTRA_GENERATOR} - ${CMAKE_GENERATOR}")
  else(CMAKE_EXTRA_GENERATOR)
    set(CMAKE_GEN "${CMAKE_GENERATOR}")
  endif(CMAKE_EXTRA_GENERATOR)


  #message("HDF5_DIR=${HDF5_DIR}")
  #message("CMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}")
  #message("CMAKE_C_COMPILER=${CMAKE_C_COMPILER}")
  SET(EXT_CMAKE_C_FLAGS ${CMAKE_C_FLAGS})
  SET(EXT_CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS})
  IF(NOT APPLE)
  LIST(APPEND EXT_CMAKE_C_FLAGS -D_XOPEN_SOURCE=600)
  LIST(APPEND EXT_CMAKE_CXX_FLAGS -D_XOPEN_SOURCE=600)
  ENDIF(NOT APPLE)


  set(CMAKE_EXTERNAL_PROJECT_ARGS
        -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
        -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
        -DCMAKE_LINKER:FILEPATH=${CMAKE_LINKER}
        -DCMAKE_CXX_FLAGS:STRING=${EXT_CMAKE_CXX_FLAGS}
        -DCMAKE_CXX_FLAGS_DEBUG:STRING=${CMAKE_CXX_FLAGS_DEBUG}
        -DCMAKE_CXX_FLAGS_MINSIZEREL:STRING=${CMAKE_CXX_FLAGS_MINSIZEREL}
        -DCMAKE_CXX_FLAGS_RELEASE:STRING=${CMAKE_CXX_FLAGS_RELEASE}
        -DCMAKE_CXX_FLAGS_RELWITHDEBINFO:STRING=${CMAKE_CXX_FLAGS_RELWITHDEBINFO}
        -DCMAKE_C_FLAGS:STRING=${EXT_CMAKE_C_FLAGS}
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
        -DNETCDF_LIBRARY:STRING=${NETCDF_LIBRARY}
       )
  if(APPLE)
    list(APPEND CMAKE_EXTERNAL_PROJECT_ARGS
      -DCMAKE_OSX_ARCHITECTURES:STRING=${CMAKE_OSX_ARCHITECTURES}
      -DCMAKE_OSX_SYSROOT:STRING=${CMAKE_OSX_SYSROOT}
      -DCMAKE_OSX_DEPLOYMENT_TARGET:STRING=${CMAKE_OSX_DEPLOYMENT_TARGET}
    )
  endif(APPLE)

  IF(USE_SYSTEM_EXPAT_ITK)
   list(APPEND CMAKE_EXTERNAL_PROJECT_ARGS
    -DITK_USE_SYSTEM_EXPAT:BOOL=${USE_SYSTEM_EXPAT_ITK}
    -DEXPAT_INCLUDE_DIR:PATH=${EXPAT_INCLUDE_DIR}
    -DEXPAT_LIBRARY:PATH=${EXPAT_LIBRARY}
    )
  ENDIF()

  # ITK 4.14's bundled libpng references ARM-NEON symbols it never compiles on
  # Apple Silicon (undefined _png_init_filter_functions_neon at link time).
  # Use the system libpng instead when requested.  We locate libpng directly
  # rather than via FIND_PACKAGE(PNG), because FindPNG pulls in FindZLIB, which
  # mis-resolves against the superbuild's staged/keg-only zlib at configure time.
  # ITK's own configure runs FIND_PACKAGE(PNG) with the paths and ZLIB below.
  IF(USE_SYSTEM_PNG)
   FIND_LIBRARY(SYSTEM_PNG_LIBRARY NAMES png png16 libpng16 libpng)
   FIND_PATH(SYSTEM_PNG_INCLUDE_DIR png.h PATH_SUFFIXES libpng libpng16)
   IF(NOT SYSTEM_PNG_LIBRARY OR NOT SYSTEM_PNG_INCLUDE_DIR)
     MESSAGE(FATAL_ERROR "USE_SYSTEM_PNG is ON but the system libpng was not found "
       "(SYSTEM_PNG_LIBRARY=${SYSTEM_PNG_LIBRARY}, SYSTEM_PNG_INCLUDE_DIR=${SYSTEM_PNG_INCLUDE_DIR}). "
       "Install libpng (e.g. 'brew install libpng') or configure with -DUSE_SYSTEM_PNG=OFF.")
   ENDIF()
   MESSAGE(STATUS "ITK: using system libpng ${SYSTEM_PNG_LIBRARY} (include ${SYSTEM_PNG_INCLUDE_DIR})")
   list(APPEND CMAKE_EXTERNAL_PROJECT_ARGS
    -DITK_USE_SYSTEM_PNG:BOOL=ON
    -DPNG_LIBRARY:FILEPATH=${SYSTEM_PNG_LIBRARY}
    -DPNG_PNG_INCLUDE_DIR:PATH=${SYSTEM_PNG_INCLUDE_DIR}
    )
  ENDIF()

  SET(HDF5_LIB_SUFFIX ".a")

  IF(MT_BUILD_SHARED_LIBS)
    SET(ITK_SHARED_LIBRARY "ON")

    IF(APPLE)
        SET(HDF5_LIB_SUFFIX ".dylib")
    ELSE(APPLE)
        SET(HDF5_LIB_SUFFIX ".so")
    ENDIF(APPLE)

  ELSE(MT_BUILD_SHARED_LIBS)
      SET(HDF5_LIB_SUFFIX    ".a")
      SET(ITK_SHARED_LIBRARY "OFF")
  ENDIF(MT_BUILD_SHARED_LIBS)

  # Derive HDF5 component library paths.
  # FindHDF5.cmake now sets HDF5_CXX_LIBRARY, HDF5_HL_LIBRARY, HDF5_HL_CXX_LIBRARY
  # when the libraries are found.  Fall back to string replacement only as last resort.

  IF(HDF5_CXX_LIBRARY)
   SET(HDF5_CPP_LIBRARY "${HDF5_CXX_LIBRARY}")
  ELSE()
   STRING(REPLACE "libhdf5" "libhdf5_cpp" HDF5_CPP_LIBRARY "${HDF5_LIBRARY}")
  ENDIF()

  IF(NOT HDF5_HL_LIBRARY)
   STRING(REPLACE "libhdf5" "libhdf5_hl"  HDF5_HL_LIBRARY "${HDF5_LIBRARY}")
  ENDIF()

  IF(HDF5_HL_CXX_LIBRARY)
   SET(HDF5_HL_CPP_LIBRARY "${HDF5_HL_CXX_LIBRARY}")
  ELSEIF(NOT HDF5_HL_CPP_LIBRARY)
   STRING(REPLACE "libhdf5" "libhdf5_hl_cpp" HDF5_HL_CPP_LIBRARY "${HDF5_LIBRARY}")
  ENDIF()

  IF(NOT HDF5_BIN_DIR)
    # Try to find h5diff to determine the HDF5 binary directory
    FIND_PROGRAM(_hdf5_h5diff_exe NAMES h5diff)
    IF(_hdf5_h5diff_exe)
      GET_FILENAME_COMPONENT(HDF5_BIN_DIR "${_hdf5_h5diff_exe}" DIRECTORY)
    ELSE()
      STRING(REPLACE "include" "bin" HDF5_BIN_DIR  "${HDF5_INCLUDE_DIR}")
    ENDIF()
  ENDIF()

  message("HDF5_LIBRARY=${HDF5_LIBRARY}")
  message("HDF5_CPP_LIBRARY=${HDF5_CPP_LIBRARY}")
  message("HDF5_HL_LIBRARY=${HDF5_HL_LIBRARY}")
  message("HDF5_HL_CPP_LIBRARY=${HDF5_HL_CPP_LIBRARY}")
  message("HDF5_BIN_DIR=${HDF5_BIN_DIR}")

  # Point ITK at our staged HDF5 via CONFIG mode only. ITK's itk-module-init.cmake tries
  # `find_package(HDF5 NO_MODULE COMPONENTS CXX C shared)` first and only falls back to the
  # (fragile) module-mode FindHDF5 if that fails. Feeding a real HDF5_DIR makes the config
  # find succeed, so module mode never runs. This is deliberately robust against the system
  # HDF5 present on this box (/usr/bin/h5cc, /usr/lib/.../hdf5/serial): module-mode FindHDF5
  # otherwise either grabs that Debian HDF5 or chokes on our h5cc/h5c++ wrappers (which bake
  # in the not-yet-existing final /install prefix). HDF5_DIR resolves to
  # ${staging}/${install}/share/cmake/hdf5 (installed there because BuildHDF5 now sets
  # HDF5_EXTERNALLY_CONFIGURED=OFF and HDF5_INSTALL_CMAKE_DIR=share/cmake/hdf5).
  SET(CMAKE_ITK_HDF5_SETTINGS
    -DHDF5_DIR:PATH=${HDF5_DIR}
    -DHDF5_DIFF_EXECUTABLE:FILEPATH=${HDF5_BIN_DIR}/h5diff
  )





  # Pinned to release-4.14 branch tip (2026-08-05). No v4.14.X release tag has
  # been cut yet; bump this SHA when upstream pushes a meaningful fix. This tip
  # adds modern-toolchain fixes: spFactor.c C23 prototypes, dropping Carbon-era
  # fp.h from the bundled libpng on macOS, and CMake 4.x support.
  #
  # It also carries InsightSoftwareConsortium/ITK#6756, which gives ITK's
  # bundled znzlib the itk_* symbol mangling its niftiio has had since 2017.
  # Without it ITKznz exported plain znzopen/znzread/znzseek/..., which
  # interpose over any other znzlib in the same binary -- the reason a system
  # NIfTI could not be combined with the ITK tools.
  GET_PACKAGE(
    "https://github.com/InsightSoftwareConsortium/ITK/archive/6073b9688acd38e8defe1f25b5ce5faf66861789.tar.gz"
    "cd4d0d42a24a4ccd994eee92dd012733"
    "InsightToolkit-4.14-6073b96.tar.gz"
    ITKv4_PATH)


  ExternalProject_Add(ITKv4
    URL "${ITKv4_PATH}"
    URL_MD5 "cd4d0d42a24a4ccd994eee92dd012733"
    UPDATE_COMMAND ""
    SOURCE_DIR ITKv4
    BINARY_DIR ITKv4-build
    CMAKE_GENERATOR ${CMAKE_GEN}
    CMAKE_ARGS
        -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
        -DBUILD_SHARED_LIBS:BOOL=${ITK_SHARED_LIBRARY}
        -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}
        -DCMAKE_SKIP_RPATH:BOOL=OFF
        -DCMAKE_SKIP_INSTALL_RPATH:BOOL=OFF
        -DMACOSX_RPATH:BOOL=ON
        -DCMAKE_INSTALL_RPATH:PATH=${install_prefix}/lib${LIB_SUFFIX}
        ${CMAKE_EXTERNAL_PROJECT_ARGS}
        ${CMAKE_ITK_HDF5_SETTINGS}
        -DBUILD_EXAMPLES:BOOL=OFF
        -DBUILD_TESTING:BOOL=OFF
        -DModule_ITKReview:BOOL=ON
        -DModule_ITKIOMINC:BOOL=ON
        -DModule_ITKIOTransformMINC:BOOL=ON
        -DModule_Cuberille:BOOL=ON
        -DModule_MGHIO:BOOL=ON
        -DITK_USE_SYSTEM_MINC:BOOL=ON
        -DITK_USE_SYSTEM_HDF5:BOOL=ON
        -DITK_USE_SYSTEM_ZLIB:BOOL=ON
        -DHAVE_ZLIB:BOOL=ON
        -DITK_USE_FFTWD:BOOL=ON
        -DITK_USE_FFTWF:BOOL=ON
        -DITK_USE_SYSTEM_FFTW:BOOL=ON
        -DFFTWD_LIB:FILEPATH=${FFTW3_LIBRARY}
        -DFFTWD_THREADS_LIB:FILEPATH=${FFTW3_THREADS_LIBRARY}
        -DFFTWF_LIB:FILEPATH=${FFTW3F_LIBRARY}
        -DFFTWF_THREADS_LIB:FILEPATH=${FFTW3F_THREADS_LIBRARY}
        -DFFTW_INCLUDE_PATH:PATH=${FFTW3_INCLUDE_DIR}
        -DLIBMINC_DIR:PATH=${minc_dir}
#        -DHDF5_DIFF_EXECUTABLE:FILEPATH=${HDF5_BIN_DIR}/h5diff
#        -DHDF5_CXX_INCLUDE_DIR:PATH=${HDF5_INCLUDE_DIR}
#        -DHDF5_C_INCLUDE_DIR:PATH=${HDF5_INCLUDE_DIR}
#        -DHDF5_hdf5_LIBRARY:FILEPATH=${HDF5_LIBRARY}
#        -DHDF5_hdf5_cpp_LIBRARY:FILEPATH=${HDF5_CPP_LIBRARY}
#        -DHDF5_hdf5_c_LIBRARY:FILEPATH=${HDF5_C_LIBRARY}
#        -DHDF5_hdf5_LIBRARY_RELEASE:FILEPATH=${HDF5_LIBRARY}
#        -DHDF5_hdf5_cpp_LIBRARY_RELEASE:FILEPATH=${HDF5_CPP_LIBRARY}
#        -DHDF5_hdf5_LIBRARY_DEBUG:FILEPATH=${HDF5_LIBRARY}
#        -DHDF5_hdf5_cpp_LIBRARY_DEBUG:FILEPATH=${HDF5_CPP_LIBRARY}
#        -DHDF5_DIR:PATH=HDF5_DIR-NOTFOUND
#        -DHDF5_Fortran_COMPILER_EXECUTABLE:FILEPATH=''
#        -DHDF5_CXX_COMPILER_EXECUTABLE:FILEPATH=${HDF5_BIN_DIR}/h5c++
#        -DHDF5_C_COMPILER_EXECUTABLE:FILEPATH=${HDF5_BIN_DIR}/h5cc
        -DZLIB_LIBRARY:PATH=${ZLIB_LIBRARY}
        -DZLIB_INCLUDE_DIR:PATH=${ZLIB_INCLUDE_DIR}
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
