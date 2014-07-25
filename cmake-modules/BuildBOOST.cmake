macro(build_BOOST install_prefix staging_prefix)

  ExternalProject_Add(BOOST
  URL  "http://sourceforge.net/projects/boost/files/boost/1.56.0.beta.1/boost-1_56_0_b1.tar.gz"
  URL_MD5 "b51810be6737e73a4deee70e84895ca7"
#  GIT_REPOSITORY "https://github.com/boostorg/boost.git"
  GIT_TAG "master"
  UPDATE_COMMAND ""
  SOURCE_DIR BOOST
  LIST_SEPARATOR :::  
  BUILD_IN_SOURCE 1
  CONFIGURE_COMMAND CXXFLAGS=${CMAKE_CXX_FLAGS} CFLAGS=${CMAKE_C_FLAGS} CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} ./bootstrap.sh --without-libraries=atomic,chrono,context,date_time,exception,filesystem,graph,graph_parallel,iostreams,locale,log,math,mpi,program_options,python,random,regex,serialization,signals,test,timer,wave --prefix=${install_prefix}
  INSTALL_DIR     "${staging_prefix}"
  BUILD_COMMAND   ./b2 
  INSTALL_COMMAND ./b2 stage --stagedir=${staging_prefix}/${install_prefix}
)

SET(BOOST_DIR ${CMAKE_CURRENT_BINARY_DIR}/BOOST)

endmacro(build_BOOST)
