file(DOWNLOAD 
          "https://github.com/BIC-MNI/man-pages/releases/download/release-0.0.99/minc-man-pages-0.0.99.tar.gz" "${CMAKE_CURRENT_BINARY_DIR}/minc-man-pages-0.0.99.tar.gz"
          EXPECTED_MD5  "f1bf82178d4c426123a43f4ad4ca571f" SHOW_PROGRESS )

add_custom_target( 
    unpack_man_pages ALL
    cmake -E tar zxf ${CMAKE_CURRENT_BINARY_DIR}/minc-man-pages-0.0.99.tar.gz
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/minc-man-pages-0.0.99.tar.gz
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Unpacking minc-man-pages-0.0.99.tar.gz" VERBATIM
  )

 INSTALL(DIRECTORY 
      ${CMAKE_CURRENT_BINARY_DIR}/man/man1
  DESTINATION 
      man )