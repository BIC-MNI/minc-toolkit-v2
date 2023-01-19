macro(build_gsl install_prefix staging_prefix)

  IF(CMAKE_BUILD_TYPE STREQUAL Release)
    SET(EXT_C_FLAGS   "${CMAKE_C_FLAGS}   ${CMAKE_C_FLAGS_RELEASE} ")
    SET(EXT_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE} ")
    SET(EXT_LDFLAGS   "-L${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX} ${CMAKE_MODULE_LINKER_FLAGS} ${CMAKE_MODULE_LINKER_FLAGS_RELEASE}")
  ELSE()
    SET(EXT_C_FLAGS   "${CMAKE_C_FLAGS}   ${CMAKE_C_FLAGS_DEBUG}")
    SET(EXT_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}")
    SET(EXT_LDFLAGS   "-L${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX} ${CMAKE_MODULE_LINKER_FLAGS} ${CMAKE_MODULE_LINKER_FLAGS_DEBUG}" )
  ENDIF()

  IF(APPLE)
    SET(EXT_C_FLAGS   "${EXT_C_FLAGS}   -isysroot ${CMAKE_OSX_SYSROOT}")
    SET(EXT_CXX_FLAGS "${EXT_CXX_FLAGS} -isysroot ${CMAKE_OSX_SYSROOT}")
  ENDIF()

GET_PACKAGE("https://ftp.gnu.org/gnu/gsl/gsl-2.7.tar.gz" "9e47e81caaebcd92b7aca27a5348df74" "gsl-2.7.tar.gz" GSL_PATH ) 

ExternalProject_Add(GSL
        SOURCE_DIR GSL
        URL "${GSL_PATH}"
        URL_MD5 "9e47e81caaebcd92b7aca27a5348df74"
        BUILD_IN_SOURCE 1
        INSTALL_DIR     "${CMAKE_BINARY_DIR}/external"
        BUILD_COMMAND   $(MAKE) -s V=0 
        INSTALL_COMMAND $(MAKE) -s V=0 DESTDIR=${CMAKE_BINARY_DIR}/external install
        CONFIGURE_COMMAND  ./configure 
          --enable-silent-rules 
          --silent  
          --prefix=${install_prefix} 
          --libdir=${install_prefix}/lib${LIB_SUFFIX} 
          --with-pic 
          --disable-shared 
          --enable-static 
          "--host=${MACHINE_NAME}"
          "CXX=${CMAKE_CXX_COMPILER}"
          "CC=${CMAKE_C_COMPILER}"
          "AR=${CMAKE_C_COMPILER_AR}"
          "RANLIB=${CMAKE_C_COMPILER_RANLIB}"
          "NM=${CMAKE_NM}"
          "STRIP=${CMAKE_STRIP}"
          "CPPFLAGS=${EXT_CXX_FLAGS}"  
          "CXXFLAGS=${EXT_CXX_FLAGS}" 
          "CFLAGS=${EXT_C_FLAGS}" 
          "LDFLAGS=${EXT_LDFLAGS}"
  #        INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/external
      )

SET(GSL_INCLUDE_DIR ${install_prefix}/include )
SET(GSL_LIBRARY  ${install_prefix}/lib${LIB_SUFFIX}/libgsl.a )
SET(GSL_CBLAS_LIBRARY ${install_prefix}/lib${LIB_SUFFIX}/libgslcblas.a )
SET(GSL_VERSION "2.7")
SET(GSL_FOUND ON)
      
configure_file(${CMAKE_SOURCE_DIR}/cmake-modules/GSLConfig.cmake.in ${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX}/GSLConfig.cmake @ONLY)
      
SET(GSL_INCLUDE_DIR ${staging_prefix}/${install_prefix}/include )
SET(GSL_LIBRARY  ${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX}/libgsl.a )
SET(GSL_CBLAS_LIBRARY ${staging_prefix}/${install_prefix}/lib${LIB_SUFFIX}/libgslcblas.a )
SET(GSL_VERSION "2.7")
SET(GSL_FOUND ON)

endmacro(build_gsl)
