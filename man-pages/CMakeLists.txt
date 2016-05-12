SET(MINC_MAN_PAGES_VERSION "0.1.00")
SET(MINC_MAN_PAGES_MD5 "8b8cc666cda80b5b96c242b17b084c27")

file(DOWNLOAD 
          "https://github.com/BIC-MNI/man-pages/releases/download/release-${MINC_MAN_PAGES_VERSION}/minc-man-pages-${MINC_MAN_PAGES_VERSION}.tar.gz" "${CMAKE_CURRENT_BINARY_DIR}/minc-man-pages-${MINC_MAN_PAGES_VERSION}.tar.gz"
          EXPECTED_MD5  "${MINC_MAN_PAGES_MD5}" SHOW_PROGRESS )

add_custom_target( 
    unpack_man_pages ALL
    ${CMAKE_COMMAND} -E tar zxf ${CMAKE_CURRENT_BINARY_DIR}/minc-man-pages-${MINC_MAN_PAGES_VERSION}.tar.gz
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/minc-man-pages-${MINC_MAN_PAGES_VERSION}.tar.gz
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Unpacking minc-man-pages-${MINC_MAN_PAGES_VERSION}.tar.gz" VERBATIM
  )

 INSTALL(DIRECTORY 
      ${CMAKE_CURRENT_BINARY_DIR}/man/man1
  DESTINATION 
      man )