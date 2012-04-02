macro(build_gsl install_prefix)

ExternalProject_Add(GSL
        SOURCE_DIR GSL
        URL "http://mirrors.ibiblio.org/pub/mirrors/gnu/ftp/gnu/gsl/gsl-1.15.tar.gz"
        URL_MD5 "494ffefd90eef4ada678c306bab4030b"
        BUILD_IN_SOURCE 1
        INSTALL_DIR     "${CMAKE_BINARY_DIR}/external"
        BUILD_COMMAND   make 
        INSTALL_COMMAND make DESTDIR=${CMAKE_BINARY_DIR}/external install 
        CONFIGURE_COMMAND ./configure --prefix=/ --with-pic --disable-shared --enable-static
      )

SET(GSL_INCLUDE_DIR ${CMAKE_BINARY_DIR}/external/include )
SET(GSL_LIBRARY  ${CMAKE_BINARY_DIR}/external/lib/libgsl.a )
SET(GSL_CBLAS_LIBRARY ${CMAKE_BINARY_DIR}/external/lib/libgslcblas.a )
SET(GSL_FOUND ON)

endmacro(build_gsl)
  