macro(build_pcre install_prefix)

ExternalProject_Add(PCRE
        SOURCE_DIR PCRE
        URL "http://downloads.sourceforge.net/project/pcre/pcre/8.12/pcre-8.12.tar.gz"
        URL_MD5 "fa69e4c5d8971544acd71d1f10d59193"
        BUILD_IN_SOURCE 1
        INSTALL_DIR     "${install_prefix}"
        BUILD_COMMAND   make 
        INSTALL_COMMAND make install 
        CONFIGURE_COMMAND ./configure --prefix=${install_prefix} --with-pic --disable-shared --disable-cpp 
      )

SET(PCRE_INCLUDE_DIR ${install_prefix}/include )
SET(PCRE_LIBRARY  ${install_prefix}/lib/libpcre.a )
SET(PCRE_FOUND ON)

endmacro(build_pcre)
