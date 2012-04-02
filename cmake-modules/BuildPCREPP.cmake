macro(build_pcrepp install_prefix pcre_include pcre_lib )

ExternalProject_Add(PCREPP
  SOURCE_DIR PCREPP
  URL "http://www.daemon.de/idisk/Apps/pcre++/pcre++-0.9.5.tar.gz"
  URL_MD5 "1fe6ea8e23ece01fde2ce5fb4746acc2"
  BUILD_IN_SOURCE 1
  INSTALL_DIR     "${CMAKE_BINARY_DIR}/external"
  UPDATE_COMMAND  autoreconf -i
  BUILD_COMMAND   make 
  INSTALL_COMMAND make DESTDIR=${CMAKE_BINARY_DIR}/external install 
  CONFIGURE_COMMAND ./configure --prefix=/ --with-pic --disable-shared --with-pcre-include=${pcre_include} --with-pcre-lib=${pcre_lib} --docdir=${CMAKE_BINARY_DIR}/dummy
)

SET(PCREPP_INCLUDE_DIR ${CMAKE_BINARY_DIR}/external/include )
SET(PCREPP_LIBRARY     ${CMAKE_BINARY_DIR}/external/lib/libpcre++.a )
SET(PCREPP_FOUND ON)

endmacro(build_pcrepp)
