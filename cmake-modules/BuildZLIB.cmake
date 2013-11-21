macro(build_zlib install_prefix staging_prefix)
  
  
  #SET(CFLAGS ${CMAKE_C_FLAGS})
  #LIST(APPEND CFLAGS -fPIC)
set(ENV{CFLAGS} "${CMAKE_C_FLAGS} -fPIC")

ExternalProject_Add(ZLIB
  SOURCE_DIR ZLIB
  #URL "http://sourceforge.net/projects/libpng/files/zlib/1.2.6/zlib-1.2.6.tar.gz"
  #URL_MD5 "618e944d7c7cd6521551e30b32322f4a"
  URL  "http://zlib.net/zlib-1.2.8.tar.gz"
  URL_MD5 "44d667c142d7cda120332623eab69f40"
  BUILD_IN_SOURCE 1
  INSTALL_DIR     "${staging_prefix}"
  BUILD_COMMAND   make 
  INSTALL_COMMAND make DESTDIR=${staging_prefix} install
  CONFIGURE_COMMAND ./configure --prefix=${install_prefix} --static
)


SET(ZLIB_INCLUDE_DIR ${staging_prefix}/${install_prefix}/include )
SET(ZLIB_LIBRARY     ${staging_prefix}/${install_prefix}/lib/libz.a )
SET(ZLIB_FOUND ON)


endmacro(build_zlib)
