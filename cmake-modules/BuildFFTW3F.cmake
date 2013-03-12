macro(build_fftw3f install_prefix staging_prefix)

ExternalProject_Add(FFTW3F
        SOURCE_DIR FFTW3F
        URL "http://www.fftw.org/fftw-3.2.2.tar.gz"
        URL_MD5 "b616e5c91218cc778b5aa735fefb61ae"
        BUILD_IN_SOURCE 1
        INSTALL_DIR     "${staging_prefix}"
        BUILD_COMMAND   make 
        INSTALL_COMMAND make DESTDIR=${staging_prefix} install 
        CONFIGURE_COMMAND ./configure --prefix=${install_prefix} --with-pic --disable-shared --enable-float
#        INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/external
      )

SET(FFTW3F_INCLUDE_DIR ${staging_prefix}/${install_prefix}/include )
SET(FFTW3F_LIBRARY  ${staging_prefix}/${install_prefix}/lib/libfftw3f.a )
SET(FFTW3F_FOUND ON)


endmacro(build_fftw3f)
