macro(build_nifti install_prefix staging_prefix)

  if(CMAKE_EXTRA_GENERATOR)
    set(CMAKE_GEN "${CMAKE_EXTRA_GENERATOR} - ${CMAKE_GENERATOR}")
  else()
    set(CMAKE_GEN "${CMAKE_GENERATOR}")
  endif()

  set_property(DIRECTORY PROPERTY EP_STEP_TARGETS configure build test)

  SET(HDF_CMAKE_CXX_FLAGS_RELEASE ${CMAKE_CXX_FLAGS_RELEASE})
  SET(HDF_CMAKE_C_FLAGS_RELEASE   ${CMAKE_C_FLAGS_RELEASE})

  SET(HDF_CMAKE_CXX_FLAGS_DEBUG   ${CMAKE_CXX_FLAGS_DEBUG})
  SET(HDF_CMAKE_C_FLAGS_DEBUG     ${CMAKE_C_FLAGS_DEBUG})

  SET(NIFTI_CMAKE_CXX_FLAGS "-fPIC ${CMAKE_CXX_FLAGS} -I${ZLIB_INCLUDE_DIR}")
  SET(NIFTI_CMAKE_C_FLAGS   "-fPIC ${CMAKE_C_FLAGS} -I${ZLIB_INCLUDE_DIR}")

  GET_PACKAGE("https://github.com/NIFTI-Imaging/nifti_clib/archive/refs/tags/v3.0.0.tar.gz" "ee40068103775a181522166e435ee82d" "nifti_clib-3.0.0.tar.gz" NIFTILIB_PATH )

  ExternalProject_Add(NIFTI
    SOURCE_DIR NIFTI
    BINARY_DIR NIFTI-build
    URL "${NIFTILIB_PATH}"
    URL_HASH SHA256=fe6cb1076974df01844f3f4dab1aa844953b3bc1d679126c652975158573d03d
    # Mangle all exported nifti/znz symbols to a minc_ prefix so libminc's copy
    # cannot collide with ITK's own bundled niftiio (ITK has no
    # ITK_USE_SYSTEM_NIFTI switch). Single source of truth lives in the libminc
    # submodule (nifti_mangle.h / PatchNiftiMangle.cmake).
    PATCH_COMMAND ${CMAKE_COMMAND}
        -DSRC=<SOURCE_DIR>
        -DMANGLE=${CMAKE_SOURCE_DIR}/libminc/cmake-modules/nifti_mangle.h
        -P ${CMAKE_SOURCE_DIR}/libminc/cmake-modules/PatchNiftiMangle.cmake
    CMAKE_GENERATOR ${CMAKE_GEN}
    CMAKE_ARGS
            -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
            -DBUILD_SHARED_LIBS:BOOL=OFF
            -DCMAKE_SKIP_RPATH:BOOL=OFF
            -DCMAKE_SKIP_INSTALL_RPATH:BOOL=OFF
            -DMACOSX_RPATH:BOOL=ON
            -DCMAKE_INSTALL_RPATH:PATH=${install_prefix}/${CMAKE_INSTALL_LIBDIR}
            -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}
            "-DCMAKE_CXX_FLAGS_RELEASE:STRING=${NIFTI_CMAKE_CXX_FLAGS_RELEASE}"
            "-DCMAKE_C_FLAGS_RELEASE:STRING=${NIFTI_CMAKE_C_FLAGS_RELEASE}"
            "-DCMAKE_CXX_FLAGS_DEBUG:STRING=${NIFTI_CMAKE_CXX_FLAGS_DEBUG}"
            "-DCMAKE_C_FLAGS_DEBUG:STRING=${NIFTI_CMAKE_C_FLAGS_DEBUG}"
            "-DCMAKE_CXX_FLAGS:STRING=${NIFTI_CMAKE_CXX_FLAGS}"
            "-DCMAKE_C_FLAGS:STRING=${NIFTI_CMAKE_C_FLAGS}"
            -DCMAKE_EXE_LINKER_FLAGS:STRING=${CMAKE_EXE_LINKER_FLAGS}
            -DCMAKE_MODULE_LINKER_FLAGS:STRING=${CMAKE_MODULE_LINKER_FLAGS}
            -DCMAKE_SHARED_LINKER_FLAGS:STRING=${CMAKE_SHARED_LINKER_FLAGS}
            -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
            -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
            -DZLIB_INCLUDE_DIR:PATH=${ZLIB_INCLUDE_DIR}
            -DZLIB_LIBRARY:FILEPATH=${ZLIB_LIBRARY}
            -DGIT_REPO_VERSION:STRING=3.0.0
            -DNIFTI_BUILD_APPLICATIONS:BOOL=OFF
            -DNIFTI_BUILD_TESTING:BOOL=OFF
            -DBUILD_TESTING:BOOL=OFF
            -DUSE_NIFTI2_CODE:BOOL=OFF
            -DUSE_NIFTICDF_CODE:BOOL=OFF
            -DNIFTI_INSTALL_NO_DOCS:BOOL=ON

    INSTALL_COMMAND $(MAKE) install DESTDIR=${staging_prefix}
    INSTALL_DIR ${staging_prefix}/${install_prefix}
  )

SET(NIFTI_LIBRARY     ${staging_prefix}/${install_prefix}/${CMAKE_INSTALL_LIBDIR}/libniftiio.a )
SET(NIFTI_INCLUDE_DIR ${staging_prefix}/${install_prefix}/include/nifti )
SET(ZNZ_LIBRARY       ${staging_prefix}/${install_prefix}/${CMAKE_INSTALL_LIBDIR}/libznz.a )
SET(ZNZ_INCLUDE_DIR   ${staging_prefix}/${install_prefix}/include/nifti )
SET(NIFTI_FOUND ON)

endmacro()
