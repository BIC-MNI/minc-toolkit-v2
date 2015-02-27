macro(build_freetype install_prefix staging_prefix  zlib_include_dir zlib_library zlib_dir)

  IF(CMAKE_BUILD_TYPE STREQUAL Release)
    SET(EXT_C_FLAGS   "${CMAKE_C_FLAGS}   ${CMAKE_C_FLAGS_RELEASE} -I${staging_prefix}/${install_prefix}/include")
    SET(EXT_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE} -I${staging_prefix}/${install_prefix}/include")
    SET(EXT_LDFLAGS   "-L${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX} ${CMAKE_MODULE_LINKER_FLAGS} ${CMAKE_MODULE_LINKER_FLAGS_RELEASE}")
  ELSE()
    SET(EXT_C_FLAGS   "${CMAKE_C_FLAGS}    ${CMAKE_C_FLAGS_DEBUG} -I${staging_prefix}/${install_prefix}/include")
    SET(EXT_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG} -I${staging_prefix}/${install_prefix}/include")
    SET(EXT_LDFLAGS   "-L${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX} ${CMAKE_MODULE_LINKER_FLAGS} ${CMAKE_MODULE_LINKER_FLAGS_DEBUG}")
  ENDIF()

  ExternalProject_Add(FREETYPE
          SOURCE_DIR FREETYPE
          URL "http://mirror.csclub.uwaterloo.ca/nongnu//freetype/freetype-2.5.5.tar.gz"
          URL_MD5 "7448edfbd40c7aa5088684b0a3edb2b8"
          BUILD_IN_SOURCE 1
          INSTALL_DIR     "${CMAKE_BINARY_DIR}/external"
          BUILD_COMMAND   $(MAKE) 
          INSTALL_COMMAND $(MAKE) DESTDIR=${CMAKE_BINARY_DIR}/external install 
          CONFIGURE_COMMAND  ./configure --prefix=${install_prefix} --with-pic --disable-shared --without-harfbuzz --without-bzip2  --without-png --with-zlib --enable-static CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} "CPPFLAGS=${EXT_CXX_FLAGS}"  "CXXFLAGS=${EXT_CXX_FLAGS}" "CFLAGS=${EXT_C_FLAGS}" "LDFLAGS=${EXT_LDFLAGS}"
  #        INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/external
        )
        
endmacro(build_freetype)
  