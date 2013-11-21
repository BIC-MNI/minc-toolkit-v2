macro(build_pcrepp install_prefix staging_prefix pcre_include pcre_lib )

ExternalProject_Add(PCREPP
  SOURCE_DIR PCREPP
  URL "http://www.daemon.de/idisk/Apps/pcre++/pcre++-0.9.5.tar.gz"
  URL_MD5 "1fe6ea8e23ece01fde2ce5fb4746acc2"
  BUILD_IN_SOURCE 1
  INSTALL_DIR     "${staging_prefix}"
  UPDATE_COMMAND  autoreconf -i
  BUILD_COMMAND   make 
  INSTALL_COMMAND make DESTDIR=${staging_prefix} install 
  CONFIGURE_COMMAND CFLAGS="${CMAKE_C_FLAGS}" LDFLAGS="${CMAKE_MODULE_LINKER_FLAGS}" CXXFLAGS="${CMAKE_CXX_FLAGS}"  CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER}  ./configure --prefix=/ --with-pic --disable-shared --with-pcre-include=${pcre_include} --with-pcre-lib=${pcre_lib} --docdir=${CMAKE_BINARY_DIR}/dummy
)

SET(PCREPP_INCLUDE_DIR ${staging_prefix}/include )
SET(PCREPP_LIBRARY     ${staging_prefix}/lib/libpcre++.a )
SET(PCREPP_FOUND ON)

endmacro(build_pcrepp)
