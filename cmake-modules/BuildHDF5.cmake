macro(build_hdf5 install_prefix staging_prefix zlib_include_dir zlib_library)

get_filename_component(zlib_library_dir ${zlib_library} PATH)

ExternalProject_Add(HDF5
  SOURCE_DIR HDF5
  URL "http://www.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8.11/src/hdf5-1.8.11.tar.gz"
  URL_MD5 "1a4cc04f7dbe34e072ddcf3325717504"
  CMAKE_GENERATOR ${CMAKE_GEN}
  CMAKE_ARGS
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
      -DBUILD_SHARED_LIBS:BOOL=OFF
      -DBUILD_STATIC_EXECS:BOOL=ON
      -DCMAKE_SKIP_RPATH:BOOL=ON
      -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}
      -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
      -DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS}
      -DCMAKE_EXE_LINKER_FLAGS=${CMAKE_EXE_LINKER_FLAGS}
      -DCMAKE_MODULE_LINKER_FLAGS=${CMAKE_MODULE_LINKER_FLAGS}
      -DCMAKE_SHARED_LINKER_FLAGS=${CMAKE_SHARED_LINKER_FLAGS}
      -DHDF5_BUILD_CPP_LIB:BOOL=ON
      -DHDF5_BUILD_TOOLS:BOOL=ON
      -DHDF5_ENABLE_Z_LIB_SUPPORT=ON
      -DZLIB_USE_EXTERNAL:BOOL=ON
      -DZLIB_INCLUDE_DIR:PATH=${zlib_include_dir}
      -DZLIB_LIBRARY:STRING=${zlib_library}
      -DZLIB_DIR:PATH=${zlib_library_dir}
  INSTALL_COMMAND make install DESTDIR=${staging_prefix}
  INSTALL_DIR ${staging_prefix}/${install_prefix}
)

SET(HDF5_INCLUDE_DIR ${staging_prefix}/${install_prefix}/include )
SET(HDF5_LIBRARY     ${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX}/libhdf5.a )
SET(HDF5_FOUND ON)

endmacro(build_hdf5)
