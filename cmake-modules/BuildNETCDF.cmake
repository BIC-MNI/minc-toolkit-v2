macro(build_netcdf install_prefix staging_prefix)

ExternalProject_Add(NETCDF 
  SOURCE_DIR NETCDF
  URL "ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.2.1.tar.gz"
  URL_MD5 "a8603acfd6b95bd885ef0d225c16ce9f"
  BUILD_IN_SOURCE 1
  INSTALL_DIR     "${staging_prefix}"
  BUILD_COMMAND   make 
  INSTALL_COMMAND make DESTDIR=${staging_prefix} install 
  CONFIGURE_COMMAND ./configure --prefix=${install_prefix} --with-pic --disable-doxygen --disable-hdf4 --disable-netcdf-4 --disable-shared --disable-dap
#  INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/external
)

SET(NETCDF_LIBRARY     ${staging_prefix}/${install_prefix}/lib/libnetcdf.a )
SET(NETCDF_INCLUDE_DIR ${staging_prefix}/${install_prefix}/include )
SET(NETCDF_FOUND ON)




endmacro(build_netcdf)
