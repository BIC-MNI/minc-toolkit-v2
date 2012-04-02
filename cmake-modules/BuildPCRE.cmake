macro(build_pcre install_prefix)

ExternalProject_Add(PCRE
  SOURCE_DIR PCRE
  URL "http://downloads.sourceforge.net/project/pcre/pcre/8.12/pcre-8.12.tar.gz"
  URL_MD5 "fa69e4c5d8971544acd71d1f10d59193"
  BUILD_IN_SOURCE 1
  INSTALL_DIR     "${CMAKE_BINARY_DIR}/external"
  BUILD_COMMAND   make 
  INSTALL_COMMAND make DESTDIR=${CMAKE_BINARY_DIR}/external install 
  CONFIGURE_COMMAND ./configure --prefix=/ --with-pic --disable-shared --enable-cpp 
)

SET(PCRE_INCLUDE_DIR  ${CMAKE_BINARY_DIR}/external/include )
SET(PCRE_LIBRARY      ${CMAKE_BINARY_DIR}/external/lib/libpcre.a )
SET(PCRECPP_LIBRARY   ${CMAKE_BINARY_DIR}/external/lib/libpcrecpp.a )
SET(PCRE_FOUND ON)
 

endmacro(build_pcre)
