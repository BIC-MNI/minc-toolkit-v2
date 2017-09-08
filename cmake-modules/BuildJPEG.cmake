macro(build_jpeg install_prefix staging_prefix)

  IF(CMAKE_BUILD_TYPE STREQUAL Release)
    SET(EXT_C_FLAGS   "${CMAKE_C_FLAGS}   ${CMAKE_C_FLAGS_RELEASE} -I${staging_prefix}/${install_prefix}/include")
    SET(EXT_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE} -I${staging_prefix}/${install_prefix}/include")
    SET(EXT_LDFLAGS   "-L${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX} ${CMAKE_MODULE_LINKER_FLAGS} ${CMAKE_MODULE_LINKER_FLAGS_RELEASE}")
  ELSE()
    SET(EXT_C_FLAGS   "${CMAKE_C_FLAGS}    ${CMAKE_C_FLAGS_DEBUG} -I${staging_prefix}/${install_prefix}/include")
    SET(EXT_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG} -I${staging_prefix}/${install_prefix}/include")
    SET(EXT_LDFLAGS   "-L${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX} ${CMAKE_MODULE_LINKER_FLAGS} ${CMAKE_MODULE_LINKER_FLAGS_DEBUG}")
  ENDIF()

  GET_PACKAGE("http://ijg.org/files/jpegsrc.v9a.tar.gz" "3353992aecaee1805ef4109aadd433e7" "pegsrc.v9a.tar.gz" LIBJPEG_PATH ) 

  ExternalProject_Add(JPEG
          SOURCE_DIR JPEG
          URL "${LIBJPEG_PATH}"
          URL_MD5 "3353992aecaee1805ef4109aadd433e7"
          BUILD_IN_SOURCE 1
          INSTALL_DIR     "${CMAKE_BINARY_DIR}/external"
          BUILD_COMMAND   $(MAKE) 
          INSTALL_COMMAND $(MAKE) DESTDIR=${CMAKE_BINARY_DIR}/external install 
          CONFIGURE_COMMAND  ./configure --prefix=${install_prefix} --with-pic --disable-shared --enable-static CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} "CPPFLAGS=${EXT_CXX_FLAGS}" "CXXFLAGS=${EXT_CXX_FLAGS}" "CFLAGS=${EXT_C_FLAGS}" "LDFLAGS=${EXT_LDFLAGS}"
  #        INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/external
        )

endmacro(build_jpeg)
  