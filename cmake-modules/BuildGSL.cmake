macro(build_gsl install_prefix)

ExternalProject_Add(GSL
        SOURCE_DIR GSL
        URL "http://mirrors.ibiblio.org/pub/mirrors/gnu/ftp/gnu/gsl/gsl-1.15.tar.gz"
        URL_MD5 "494ffefd90eef4ada678c306bab4030b"
        BUILD_IN_SOURCE 1
        INSTALL_DIR     "${install_prefix}"
        BUILD_COMMAND   make 
        INSTALL_COMMAND make install 
        CONFIGURE_COMMAND ./configure --prefix=${install_prefix} --with-pic --disable-shared 
      )

SET(GSL_INCLUDE_DIR ${install_prefix}/include )
SET(GSL_LIBRARY  ${install_prefix}/lib/libgsl.a )
SET(GSL_CBLAS_LIBRARY ${install_prefix}/lib/libgslcblas.a )
SET(GSL_FOUND ON)

endmacro(build_gsl)
