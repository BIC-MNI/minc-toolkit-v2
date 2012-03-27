macro(build_hdf5 install_prefix)

ExternalProject_Add(HDF5
        SOURCE_DIR HDF5
        URL "http://www.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8.8/src/hdf5-1.8.8.tar.gz"
        URL_MD5 "1196e668f5592bfb50d1de162eb16cff"
        BUILD_IN_SOURCE 1
        INSTALL_DIR     "${install_prefix}"
        BUILD_COMMAND   make 
        INSTALL_COMMAND make install 
        CONFIGURE_COMMAND ./configure --prefix=${install_prefix} --with-pic --disable-shared --disable-cxx --disable-f77 --disable-f90 --disable-examples --disable-hl --disable-docs
      )

SET(HDF5_INCLUDE_DIR ${install_prefix}/include )
SET(HDF5_LIBRARY  ${install_prefix}/lib/libhdf5.a )
SET(HDF5_FOUND ON)

endmacro(build_hdf5)
