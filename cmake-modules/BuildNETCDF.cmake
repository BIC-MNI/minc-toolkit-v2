macro(build_netcdf install_prefix staging_prefix)
  
  IF(CMAKE_BUILD_TYPE STREQUAL Release)
    SET(EXT_C_FLAGS   "${CMAKE_C_FLAGS}   ${CMAKE_C_FLAGS_RELEASE}")
    SET(EXT_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}")
  ELSE()
    SET(EXT_C_FLAGS   "${CMAKE_C_FLAGS}    ${CMAKE_C_FLAGS_DEBUG}")
    SET(EXT_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}")
  ENDIF()

  ExternalProject_Add(NETCDF 
    SOURCE_DIR NETCDF
    URL "ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.3.1.1.tar.gz"
    URL_MD5 "275c3b839088674c2f00fb3ac264bf11"
    BUILD_IN_SOURCE 1
    INSTALL_DIR     "${staging_prefix}"
    BUILD_COMMAND   make 
    INSTALL_COMMAND make DESTDIR=${staging_prefix} install 
    CONFIGURE_COMMAND ./configure --prefix=${install_prefix} --with-pic --disable-doxygen --disable-hdf4 --disable-netcdf-4 --disable-shared --disable-dap  --libdir=${install_prefix}/lib${LIB_SUFFIX} CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} "CXXFLAGS=${EXT_CXX_FLAGS}" "CFLAGS=${EXT_C_FLAGS}"
  #  INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/external
  )

  SET(NETCDF_LIBRARY     ${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX}/libnetcdf.a )
  SET(NETCDF_INCLUDE_DIR ${staging_prefix}/${install_prefix}/include )
  SET(NETCDF_FOUND ON)




endmacro(build_netcdf)
