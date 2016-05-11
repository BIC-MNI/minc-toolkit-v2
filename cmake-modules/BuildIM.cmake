macro(build_im install_prefix staging_prefix  zlib_include_dir zlib_library zlib_dir)

  IF(CMAKE_BUILD_TYPE STREQUAL Release)
    SET(EXT_C_FLAGS   "${CMAKE_C_FLAGS}   ${CMAKE_C_FLAGS_RELEASE} -I${staging_prefix}/${install_prefix}/include")
    SET(EXT_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE} -I${staging_prefix}/${install_prefix}/include")
    SET(EXT_LDFLAGS   "-L${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX} ${CMAKE_MODULE_LINKER_FLAGS} ${CMAKE_MODULE_LINKER_FLAGS_RELEASE}")
  ELSE()
    SET(EXT_C_FLAGS   "${CMAKE_C_FLAGS}    ${CMAKE_C_FLAGS_DEBUG} -I${staging_prefix}/${install_prefix}/include")
    SET(EXT_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG} -I${staging_prefix}/${install_prefix}/include")
    SET(EXT_LDFLAGS   "-L${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX} ${CMAKE_MODULE_LINKER_FLAGS} ${CMAKE_MODULE_LINKER_FLAGS_DEBUG}")
  ENDIF()

  ExternalProject_Add(IM
          SOURCE_DIR IM
          URL "http://mirrors-usa.go-parts.com/mirrors/ImageMagick/ImageMagick-6.9.3-8.tar.bz2"
          URL_MD5 "8f52a5f38598f32b0784e63a8e3e1500"
          BUILD_IN_SOURCE 1
          INSTALL_DIR     "${CMAKE_BINARY_DIR}/external"
          BUILD_COMMAND   $(MAKE) 
          INSTALL_COMMAND $(MAKE) DESTDIR=${CMAKE_BINARY_DIR}/external install 
          CONFIGURE_COMMAND  ./configure --prefix=${install_prefix}  --disable-shared --without-magick-plus-plus --without-x --enable-zero-configuration --without-gs-font-dir --without-perl --without-pango  --with-jpeg --with-png  --without-openexr --disable-docs  --with-freetype --without-xml --without-openjp2 --with-fontconfig --with-zlib  --without-lzma --without-openexr --without-bzlib "FREETYPE_CFLAGS=${staging_prefix}/${install_prefix}/include/freetype2 ${EXT_C_FLAGS}" "FREETYPE_LIBS=${EXT_LDFLAGS}" CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} "CXXFLAGS=${EXT_CXX_FLAGS}" "CFLAGS=${EXT_C_FLAGS}" "LDFLAGS=${EXT_LDFLAGS}"
  #        INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/external
        )

endmacro(build_im)
  
