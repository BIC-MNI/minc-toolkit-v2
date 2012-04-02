macro(build_fftw3f install_prefix)

ExternalProject_Add(FFTW3F
        SOURCE_DIR FFTW3F
        URL "http://www.fftw.org/fftw-3.2.2.tar.gz"
        URL_MD5 "b616e5c91218cc778b5aa735fefb61ae"
        BUILD_IN_SOURCE 1
        INSTALL_DIR     "${CMAKE_BINARY_DIR}/external"
        BUILD_COMMAND   make 
        INSTALL_COMMAND make DESTDIR=${CMAKE_BINARY_DIR}/external install 
        CONFIGURE_COMMAND ./configure --prefix=/ --with-pic --disable-shared --enable-float 
      )

SET(FFTW3F_INCLUDE_DIR ${CMAKE_BINARY_DIR}/external/include )
SET(FFTW3F_LIBRARY  ${CMAKE_BINARY_DIR}/external/lib/libfftw3f.a )
SET(FFTW3F_FOUND ON)


endmacro(build_fftw3f)
