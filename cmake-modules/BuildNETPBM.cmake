macro(build_netpbm install_prefix)

#   configure_file(${CMAKE_SOURCE_DIR}/cmake-modules/NETPBM.Makefile.common.cmake
#     ${CMAKE_CURRENT_BINARY_DIR}/NETPBM.Makefile.common @ONLY )
#   
  
  ExternalProject_Add(NETPBM
    SOURCE_DIR NETPBM
    URL "http://downloads.sourceforge.net/project/netpbm/super_stable/10.35.84/netpbm-10.35.84.tgz"
    URL_MD5 "7137f3862d73e2cdb9735040f8786887"
    BUILD_IN_SOURCE 1
    INSTALL_DIR        "${install_prefix}"
    BUILD_COMMAND      ./NETPBM.build 
    INSTALL_COMMAND    ./NETPBM.install ${install_prefix}
    CONFIGURE_COMMAND  cp ${CMAKE_SOURCE_DIR}/cmake-modules/NETPBM.Makefile.config.cmake Makefile.config
    UPDATE_COMMAND     cp ${CMAKE_SOURCE_DIR}/cmake-modules/NETPBM.build  ${CMAKE_SOURCE_DIR}/cmake-modules/NETPBM.install .
  )
  
#   ExternalProject_Add_Step(NETPBM build2
#     COMMAND      make package PKGDIR=${CMAKE_CURRENT_BINARY_DIR}/NETPBM
#     DEPENDEES    build
#     DEPENDERS    install
#   )
  
#   ExternalProject_Add_Step(NETPBM install2
#     COMMAND      cp ${CMAKE_CURRENT_BINARY_DIR}/NETPBM/pkg/include/*.h ${install_prefix}/include/
#     COMMENT      "Installing headers"
#     DEPENDEES    install
#     )
    
  SET(NETPBM_LIBRARY ${install_prefix}/lib/libnetpbm.a )
  SET(NETPBM_INCLUDE_DIR ${install_prefix}/include )
  SET(NETPBM_FOUND ON)

endmacro(build_netpbm)
