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

  GET_PACKAGE("http://mirrors-usa.go-parts.com/mirrors/ImageMagick/ImageMagick-7.0.5-0.tar.gz" "b16408790de8c98df51b34efded7952d" "ImageMagick-7.0.5-0.tar.gz" IM_PATH ) 
  
  ExternalProject_Add(IM
          SOURCE_DIR IM
          URL "${IM_PATH}"
          URL_MD5 "b16408790de8c98df51b34efded7952d"
          BUILD_IN_SOURCE 1
          INSTALL_DIR     "${CMAKE_BINARY_DIR}/external"
          BUILD_COMMAND   $(MAKE) 
          INSTALL_COMMAND $(MAKE) DESTDIR=${CMAKE_BINARY_DIR}/external install 
          CONFIGURE_COMMAND  ./configure --prefix=${install_prefix}  --disable-shared --without-magick-plus-plus --without-x --enable-zero-configuration --without-gs-font-dir --without-perl --without-pango  --with-jpeg --with-png  --without-openexr --disable-docs  --with-freetype --without-xml --without-openjp2 --with-fontconfig --with-zlib  --without-lzma --without-openexr --without-bzlib "FREETYPE_CFLAGS=${staging_prefix}/${install_prefix}/include/freetype2 ${EXT_C_FLAGS}" "FREETYPE_LIBS=${EXT_LDFLAGS}" CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} "CXXFLAGS=${EXT_CXX_FLAGS}" "CFLAGS=${EXT_C_FLAGS}" "LDFLAGS=${EXT_LDFLAGS}"
  #        INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/external
        )

endmacro(build_im)
  
