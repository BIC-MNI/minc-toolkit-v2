macro(build_png install_prefix staging_prefix  zlib_include_dir zlib_library zlib_dir)

  IF(CMAKE_BUILD_TYPE STREQUAL Release)
    SET(EXT_C_FLAGS   "${CMAKE_C_FLAGS}   ${CMAKE_C_FLAGS_RELEASE} -I${staging_prefix}/${install_prefix}/include")
    SET(EXT_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE} -I${staging_prefix}/${install_prefix}/include")
    SET(EXT_LDFLAGS   "-L${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX} ${CMAKE_MODULE_LINKER_FLAGS} ${CMAKE_MODULE_LINKER_FLAGS_RELEASE}")
  ELSE()
    SET(EXT_C_FLAGS   "${CMAKE_C_FLAGS}    ${CMAKE_C_FLAGS_DEBUG} -I${staging_prefix}/${install_prefix}/include")
    SET(EXT_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG} -I${staging_prefix}/${install_prefix}/include")
    SET(EXT_LDFLAGS   "-L${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX} ${CMAKE_MODULE_LINKER_FLAGS} ${CMAKE_MODULE_LINKER_FLAGS_DEBUG}")
  ENDIF()

  ExternalProject_Add(PNG
          SOURCE_DIR PNG
          URL "http://downloads.sourceforge.net/project/libpng/libpng16/1.6.21/libpng-1.6.21.tar.gz"
          URL_MD5 "aca36ec8e0a3b406a5912243bc243717"
          BUILD_IN_SOURCE 1
          INSTALL_DIR     "${CMAKE_BINARY_DIR}/external"
          BUILD_COMMAND   $(MAKE) 
          INSTALL_COMMAND $(MAKE) DESTDIR=${CMAKE_BINARY_DIR}/external install 
          CONFIGURE_COMMAND  ./configure --prefix=${install_prefix} --with-pic --disable-shared --enable-static CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} "CXXFLAGS=${EXT_CXX_FLAGS}" "CPPFLAGS=${EXT_CXX_FLAGS}" "CFLAGS=${EXT_C_FLAGS}" "LDFLAGS=${EXT_LDFLAGS}"  --with-zlib-prefix=${staging_prefix}/${install_prefix} 
  #        INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/external
        )

endmacro(build_png)
  
