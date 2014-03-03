macro(build_BOOST install_prefix staging_prefix)
  message("BOOST: ${install_prefix} ${staging_prefix}")

  ExternalProject_Add(BOOST
  URL  "http://sourceforge.net/projects/boost/files/boost/1.54.0/boost_1_54_0.tar.gz"
  URL_MD5 "efbfbff5a85a9330951f243d0a46e4b9"
  UPDATE_COMMAND ""
  SOURCE_DIR BOOST
  #BINARY_DIR BOOST-build
  LIST_SEPARATOR :::  
  BUILD_IN_SOURCE 1
  CONFIGURE_COMMAND ./bootstrap.sh --prefix=${BOOST_INSTALL_DIR}  --without-libraries=atomic,chrono,context,date_time,exception,filesystem,graph,graph_parallel,iostreams,locale,log,math,mpi,program_options,python,random,regex,serialization,signals,test,timer,wave --prefix=${install_prefix}
  INSTALL_DIR     "${staging_prefix}"
  BUILD_COMMAND   ./b2 
  INSTALL_COMMAND ./b2 stage --stagedir=${staging_prefix}
)

SET(BOOST_DIR ${CMAKE_CURRENT_BINARY_DIR}/BOOST)

endmacro(build_BOOST)
