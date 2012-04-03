macro(build_zlib install_prefix)

ExternalProject_Add(ZLIB
  SOURCE_DIR ZLIB
  URL "http://sourceforge.net/projects/libpng/files/zlib/1.2.6/zlib-1.2.6.tar.gz"
  URL_MD5 "618e944d7c7cd6521551e30b32322f4a"
  BUILD_IN_SOURCE 1
  INSTALL_DIR     "${CMAKE_BINARY_DIR}/external"
  BUILD_COMMAND   make 
  INSTALL_COMMAND make DESTDIR=${CMAKE_BINARY_DIR}/external install
  CONFIGURE_COMMAND CFLAGS=-fPIC ./configure --prefix=${install_prefix} --static  
)


SET(ZLIB_INCLUDE_DIR ${CMAKE_BINARY_DIR}/external/${install_prefix}/include )
SET(ZLIB_LIBRARY     ${CMAKE_BINARY_DIR}/external/${install_prefix}/lib/libz.a )
SET(ZLIB_FOUND ON)


endmacro(build_zlib)
