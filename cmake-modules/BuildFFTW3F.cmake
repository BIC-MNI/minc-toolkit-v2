macro(build_fftw3f install_prefix)

ExternalProject_Add(FFTW3F
        SOURCE_DIR FFTW3F
        URL "http://www.fftw.org/fftw-3.2.2.tar.gz"
        URL_MD5 "b616e5c91218cc778b5aa735fefb61ae"
        BUILD_IN_SOURCE 1
        INSTALL_DIR     "${install_prefix}"
        BUILD_COMMAND   make 
        INSTALL_COMMAND make DESTDIR=${CMAKE_BINARY_DIR}/fftw3f install 
        CONFIGURE_COMMAND ./configure --prefix=${install_prefix} --with-pic --disable-shared --enable-float 
      )

SET(FFTW3F_INCLUDE_DIR ${CMAKE_BINARY_DIR}/fftw3f/${install_prefix}/include )
SET(FFTW3F_LIBRARY  ${CMAKE_BINARY_DIR}/fftw3f/${install_prefix}/lib/libfftw3f.a )
SET(FFTW3F_FOUND ON)

INSTALL(DIRECTORY ${CMAKE_BINARY_DIR}/fftw3f/${CMAKE_INSTALL_PREFIX}/ 
        DESTINATION ${CMAKE_INSTALL_PREFIX})

endmacro(build_fftw3f)
