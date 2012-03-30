macro(build_netcdf install_prefix)

ExternalProject_Add(NETCDF 
  SOURCE_DIR NETCDF
  URL "ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.2.tar.gz"
  URL_MD5 "b920a6c3a30e9cd46fe96d9fb65ef17e"
  BUILD_IN_SOURCE 1
  INSTALL_DIR "${install_prefix}"
  BUILD_COMMAND   make 
  INSTALL_COMMAND make DESTDIR=${CMAKE_BINARY_DIR}/netcdf install 
  CONFIGURE_COMMAND ./configure --prefix=${install_prefix} --with-pic --disable-doxygen --disable-hdf4 --disable-netcdf-4 --disable-shared --disable-dap
)

SET(NETCDF_LIBRARY     ${CMAKE_BINARY_DIR}/netcdf/${install_prefix}/lib/libnetcdf.a )
SET(NETCDF_INCLUDE_DIR ${CMAKE_BINARY_DIR}/netcdf/${install_prefix}/include )
SET(NETCDF_FOUND ON)

INSTALL(DIRECTORY ${CMAKE_BINARY_DIR}/netcdf/${CMAKE_INSTALL_PREFIX}/ 
        DESTINATION ${CMAKE_INSTALL_PREFIX}) 


endmacro(build_netcdf)
