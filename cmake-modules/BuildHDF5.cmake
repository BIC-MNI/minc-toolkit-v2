macro(build_hdf5 install_prefix zlib_include_dir zlib_library)

ExternalProject_Add(HDF5
  SOURCE_DIR HDF5
  URL "http://www.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8.8/src/hdf5-1.8.8.tar.gz"
  URL_MD5 "1196e668f5592bfb50d1de162eb16cff"
  BUILD_IN_SOURCE 1
  INSTALL_DIR     "${CMAKE_BINARY_DIR}/external"
  BUILD_COMMAND   make 
  INSTALL_COMMAND make DESTDIR=${CMAKE_BINARY_DIR}/external install 
  CONFIGURE_COMMAND ./configure --prefix=${install_prefix} --with-zlib=${zlib_include_dir},${zlib_library} --with-pic --disable-shared --disable-cxx --disable-f77 --disable-f90 --disable-examples --disable-hl --disable-docs
#  INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/external
)

SET(HDF5_INCLUDE_DIR ${CMAKE_BINARY_DIR}/external/${install_prefix}/include )
SET(HDF5_LIBRARY     ${CMAKE_BINARY_DIR}/external/${install_prefix}/lib/libhdf5.a )
SET(HDF5_FOUND ON)

endmacro(build_hdf5)
