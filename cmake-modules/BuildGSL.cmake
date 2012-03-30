macro(build_gsl install_prefix)

ExternalProject_Add(GSL
        SOURCE_DIR GSL
        URL "http://mirrors.ibiblio.org/pub/mirrors/gnu/ftp/gnu/gsl/gsl-1.15.tar.gz"
        URL_MD5 "494ffefd90eef4ada678c306bab4030b"
        BUILD_IN_SOURCE 1
        INSTALL_DIR     "${install_prefix}"
        BUILD_COMMAND   make 
        INSTALL_COMMAND make DESTDIR=${CMAKE_BINARY_DIR}/gsl install 
        CONFIGURE_COMMAND ./configure --prefix=${install_prefix} --with-pic --disable-shared --enable-static
      )

SET(GSL_INCLUDE_DIR ${CMAKE_BINARY_DIR}/gsl/${install_prefix}/include )
SET(GSL_LIBRARY  ${CMAKE_BINARY_DIR}/gsl/${install_prefix}/lib/libgsl.a )
SET(GSL_CBLAS_LIBRARY ${CMAKE_BINARY_DIR}/gsl/${install_prefix}/lib/libgslcblas.a )
SET(GSL_FOUND ON)

INSTALL(DIRECTORY ${CMAKE_BINARY_DIR}/gsl/${CMAKE_INSTALL_PREFIX}
        DESTINATION ${CMAKE_INSTALL_PREFIX})

endmacro(build_gsl)
