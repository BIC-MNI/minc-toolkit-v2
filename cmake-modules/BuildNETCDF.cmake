
macro(build_netcdf install_prefix)

ExternalProject_Add(NETCDF 
  SOURCE_DIR NETCDF
  URL "ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.0.1.tar.gz"
  URL_MD5 "a251453c5477599f050fa4e593295186"
  BUILD_IN_SOURCE 1
  INSTALL_DIR "${install_prefix}"
  BUILD_COMMAND   make 
  INSTALL_COMMAND make install 
  CONFIGURE_COMMAND ./configure --prefix=${install_prefix} --with-pic --disable-netcdf4 --disable-hdf4 --disable-dap --disable-shared --disable-cxx --disable-f77 --disable-f90 --disable-examples --enable-v2 --disable-docs
)

SET(NETCDF_LIBRARY ${install_prefix}/lib/libnetcdf.a )
SET(NETCDF_INCLUDE_DIR ${install_prefix}/include )

endmacro(build_netcdf)