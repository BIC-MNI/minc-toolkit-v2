macro(build_hdf5 install_prefix staging_prefix)

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
  )
  
  if(APPLE)
    list(APPEND CMAKE_OSX_EXTERNAL_PROJECT_ARGS
      -DCMAKE_OSX_ARCHITECTURES:STRING=${CMAKE_OSX_ARCHITECTURES}
      -DCMAKE_OSX_SYSROOT:STRING=${CMAKE_OSX_SYSROOT}
      -DCMAKE_OSX_DEPLOYMENT_TARGET:STRING=${CMAKE_OSX_DEPLOYMENT_TARGET}
    )
  endif()

  set_property(DIRECTORY PROPERTY EP_STEP_TARGETS configure build test)

  SET(HDF_CMAKE_CXX_FLAGS_RELEASE ${CMAKE_CXX_FLAGS_RELEASE})
  SET(HDF_CMAKE_C_FLAGS_RELEASE   ${CMAKE_C_FLAGS_RELEASE})
  
  SET(HDF_CMAKE_CXX_FLAGS_DEBUG   ${CMAKE_CXX_FLAGS_DEBUG})
  SET(HDF_CMAKE_C_FLAGS_DEBUG     ${CMAKE_C_FLAGS_DEBUG})
  
  SET(HDF_CMAKE_CXX_FLAGS "-fPIC ${CMAKE_CXX_FLAGS}")
  SET(HDF_CMAKE_C_FLAGS   "-fPIC ${CMAKE_C_FLAGS}")

  GET_PACKAGE("https://github.com/HDFGroup/hdf5/releases/download/hdf5_1.14.6/hdf5-1.14.6.tar.gz" "e4defbac30f50d64e1556374aa49e574417c9e72c6b1de7a4ff88c4b1bea6e9b" "hdf5-1.14.6.tar.gz" HDF5_PATH )

ExternalProject_Add(HDF5
  URL "${HDF5_PATH}"
  URL_HASH SHA256=e4defbac30f50d64e1556374aa49e574417c9e72c6b1de7a4ff88c4b1bea6e9b
  SOURCE_DIR HDF5
  BINARY_DIR HDF5-build
  CMAKE_GENERATOR ${CMAKE_GEN}
  CMAKE_ARGS
      -DBUILD_TESTING:BOOL=OFF #${BUILD_TESTING}
      -DBUILD_SHARED_LIBS:BOOL=${MT_BUILD_SHARED_LIBS}
      -DBUILD_STATIC_EXECS:BOOL=OFF
      -DCMAKE_SKIP_RPATH:BOOL=OFF
      -DCMAKE_SKIP_INSTALL_RPATH:BOOL=OFF
      -DMACOSX_RPATH:BOOL=ON
      -DCMAKE_INSTALL_RPATH:STRING=${MT_RPATH_ORIGIN}/../lib${LIB_SUFFIX}
      -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}
      # Must be RELATIVE to the install prefix. Passing the absolute ${install_prefix}
      # made HDF5 emit a broken package config: `include(${PACKAGE_PREFIX_DIR}//app/install/-targets.cmake)`,
      # so config-mode find_package(HDF5 NO_MODULE) (ITK's preferred path) could not load it.
      # HDF5 1.14.x installs the package to this dir VERBATIM (config/cmake/HDFMacros.cmake
      # uses it as the install DESTINATION unchanged), so spell out the whole path and keep
      # it in step with HDF5_DIR below. 1.12.x appended "/hdf5" here; 1.14.x does not.
      -DHDF5_INSTALL_CMAKE_DIR:PATH=share/cmake/hdf5
      -DHDF5_NO_PACKAGES:BOOL=ON
      -DHDF5_BUILD_CPP_LIB:BOOL=ON
      -DHDF5_BUILD_TOOLS:BOOL=ON
      -DHDF5_BUILD_EXAMPLES:BOOL=OFF
      # OFF: we build HDF5 as a standalone ExternalProject, not embedded via add_subdirectory.
      # ON suppressed installation of HDF5's own CMake package (hdf5-config.cmake + targets),
      # so config-mode find_package(HDF5 NO_MODULE) — ITK's preferred, system-HDF5-proof path —
      # had nothing to load.
      -DHDF5_EXTERNALLY_CONFIGURED:BOOL=OFF
      -DHDF5_ENABLE_Z_LIB_SUPPORT:BOOL=ON
      # Let HDF5 resolve zlib itself through module-mode FindZLIB, seeded with the
      # library the superbuild already resolved. Do NOT set H5_ZLIB_HEADER here: in
      # 1.14.x that takes the "zlib already configured by the parent project" branch
      # of CMakeFilters.cmake, which sets H5_ZLIB_FOUND but never appends zlib to
      # LINK_COMP_LIBS — leaving libhdf5 with undefined deflate/inflate symbols.
      # (1.12.x appended it unconditionally, hence the flag on that version.)
      -DZLIB_USE_EXTERNAL:BOOL=OFF
      -DHDF5_MODULE_MODE_ZLIB:BOOL=ON
      # Pre-seeded cache entries short-circuit FindZLIB's find_path/find_library.
      # ZLIB_LIBRARY_RELEASE, not ZLIB_LIBRARY: HDF5 has no FindZLIB of its own, so
      # this goes to CMake's, where select_library_configurations() derives
      # ZLIB_LIBRARY from the _RELEASE entry and would overwrite anything we set.
      -DZLIB_INCLUDE_DIR:PATH=${ZLIB_INCLUDE_DIR}
      -DZLIB_LIBRARY_RELEASE:FILEPATH=${ZLIB_LIBRARY}
      ${CMAKE_EXTERNAL_PROJECT_ARGS}
  INSTALL_COMMAND $(MAKE) install DESTDIR=${staging_prefix}
  INSTALL_DIR ${staging_prefix}/${install_prefix}
#  TEST_COMMAND make test
)

SET(HDF5_LIB_SUFFIX ".a")

IF(MT_BUILD_SHARED_LIBS)
  IF(APPLE)
    IF( (CMAKE_BUILD_TYPE STREQUAL Release) OR (CMAKE_BUILD_TYPE STREQUAL RelWithDebInfo) OR (CMAKE_BUILD_TYPE STREQUAL MinSizeRel))
      SET(HDF5_LIB_SUFFIX ".dylib")
    ELSE()
      SET(HDF5_LIB_SUFFIX "_debug.dylib")
    ENDIF()
  ELSE(APPLE)
    IF((CMAKE_BUILD_TYPE STREQUAL Release) OR (CMAKE_BUILD_TYPE STREQUAL RelWithDebInfo) OR (CMAKE_BUILD_TYPE STREQUAL MinSizeRel))
      SET(HDF5_LIB_SUFFIX ".so")
    ELSE()
      SET(HDF5_LIB_SUFFIX "_debug.so")
    ENDIF()
  ENDIF(APPLE)
ELSE(MT_BUILD_SHARED_LIBS)
  IF((CMAKE_BUILD_TYPE STREQUAL Release) OR (CMAKE_BUILD_TYPE STREQUAL RelWithDebInfo) OR (CMAKE_BUILD_TYPE STREQUAL MinSizeRel))
    SET(HDF5_LIB_SUFFIX ".a")
  ELSE()
    SET(HDF5_LIB_SUFFIX "_debug.a")
  ENDIF()
ENDIF(MT_BUILD_SHARED_LIBS)

SET(HDF5_BIN_DIR     ${staging_prefix}/${install_prefix}/bin )
SET(HDF5_INCLUDE_DIR ${staging_prefix}/${install_prefix}/include )
SET(HDF5_LIBRARY_DIR ${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX} )
SET(HDF5_LIBRARY     ${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX}/libhdf5${HDF5_LIB_SUFFIX} )
# The HDF5 C library IS libhdf5; export HDF5_C_LIBRARY explicitly, plus the C++/HL component
# libraries pointing at OUR staged HDF5. Otherwise the custom FindHDF5.cmake (invoked by e.g.
# libminc's find_package(HDF5)) caches the SYSTEM libhdf5_serial_cpp/_hl, which then leak into
# consumers and mix a Debian HDF5 C++ lib with our libhdf5.so. build_hdf5() is a macro, so
# these SET() shadow the stale cache in the caller scope (as HDF5_LIBRARY already does).
SET(HDF5_C_LIBRARY   ${HDF5_LIBRARY})
SET(HDF5_CXX_LIBRARY    ${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX}/libhdf5_cpp${HDF5_LIB_SUFFIX} )
SET(HDF5_HL_LIBRARY     ${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX}/libhdf5_hl${HDF5_LIB_SUFFIX} )
SET(HDF5_HL_CXX_LIBRARY ${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX}/libhdf5_hl_cpp${HDF5_LIB_SUFFIX} )


SET(HDF5_LIBRARIES    ${HDF5_LIBRARY})
SET(HDF5_INCLUDE_DIRS ${HDF5_INCLUDE_DIR})

SET(HDF5_DIR         ${staging_prefix}/${install_prefix}/share/cmake/hdf5)
SET(HDF5_FOUND ON)

endmacro(build_hdf5)
