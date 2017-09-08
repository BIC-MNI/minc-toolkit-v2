function(GET_PACKAGE url md5 name local_url )
  IF(NOT MT_PACKAGES_PATH STREQUAL "")
    SET(DST "${MT_PACKAGES_PATH}/${name}")
    file(DOWNLOAD "${url}" "${DST}"  EXPECTED_MD5  "${md5}" SHOW_PROGRESS )
    SET(${local_url} "file://${DST}" PARENT_SCOPE)
  ELSEIF(NOT MT_PACKAGES_PATH STREQUAL "")
    SET(${local_url} "${url}" PARENT_SCOPE)
  ENDIF(NOT MT_PACKAGES_PATH STREQUAL "")
ENDFUNCTION(GET_PACKAGE)