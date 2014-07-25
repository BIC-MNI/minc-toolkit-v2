macro(build_zlib install_prefix staging_prefix)


# make a custom ZLIB configuration file

SET (ZLIB_VERSION_STRING 1.2)
SET (ZLIB_VERSION_MAJOR  1.2)
SET (ZLIB_VERSION_MINOR  8)

set(CMAKE_OSX_EXTERNAL_PROJECT_ARGS)
if(APPLE)
  list(APPEND CMAKE_OSX_EXTERNAL_PROJECT_ARGS
    -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES}
    -DCMAKE_OSX_SYSROOT=${CMAKE_OSX_SYSROOT}
    -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}
  )
endif()


ExternalProject_Add(ZLIB
  URL  "http://zlib.net/zlib-1.2.8.tar.gz"
  URL_MD5 "44d667c142d7cda120332623eab69f40"
  UPDATE_COMMAND ""
  SOURCE_DIR ZLIB
  BINARY_DIR ZLIB-build
  LIST_SEPARATOR :::  
  CMAKE_GENERATOR ${CMAKE_GEN}
  CMAKE_ARGS
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
      -DBUILD_SHARED_LIBS:BOOL=OFF
      -DCMAKE_SKIP_RPATH:BOOL=ON
      -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}
      -DCMAKE_C_FLAGS:STRING=-fPIC ${CMAKE_C_FLAGS}
      -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
  INSTALL_COMMAND make install DESTDIR=${staging_prefix} 
  INSTALL_DIR ${staging_prefix}/${install_prefix}
)




SET(ZLIB_INCLUDE_DIR ${staging_prefix}/${install_prefix}/include )
SET(ZLIB_LIBRARY     ${staging_prefix}/${install_prefix}/lib/libz.a )
SET(ZLIB_DIR         ${staging_prefix}/${install_prefix}/share/cmake/ZLIB/ )
SET(ZLIB_FOUND ON)

configure_file(${CMAKE_SOURCE_DIR}/cmake-modules/ZLIB-config.cmake.install.in ${staging_prefix}/${install_prefix}/share/cmake/ZLIB/ZLIBConfig.cmake @ONLY )



endmacro(build_zlib)
