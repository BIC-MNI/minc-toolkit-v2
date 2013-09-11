macro(build_netcdf install_prefix staging_prefix)

ExternalProject_Add(NETCDF 
  SOURCE_DIR NETCDF
  URL "ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.3.0.tar.gz"
  URL_MD5 "39fc507bf2966980fa92defecd9d2167"
  BUILD_IN_SOURCE 1
  INSTALL_DIR     "${staging_prefix}"
  BUILD_COMMAND   make 
  INSTALL_COMMAND make DESTDIR=${staging_prefix} install 
  CONFIGURE_COMMAND ./configure --prefix=${install_prefix} --with-pic --disable-doxygen --disable-hdf4 --disable-netcdf-4 --disable-shared --disable-dap  --libdir=${install_prefix}/lib${LIB_SUFFIX} CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER}
#  INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/external
)

SET(NETCDF_LIBRARY     ${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX}/libnetcdf.a )
SET(NETCDF_INCLUDE_DIR ${staging_prefix}/${install_prefix}/include )
SET(NETCDF_FOUND ON)




endmacro(build_netcdf)
