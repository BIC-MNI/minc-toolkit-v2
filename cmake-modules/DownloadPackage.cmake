# Fetch <url> into the package cache and hand back a file:// URL for the copy,
# so a rebuild does not download it again.
#
# <hash> is either an MD5 (32 hex digits) or a SHA256 (64). Taking both lets
# call sites move to SHA256 one at a time instead of all at once.
function(GET_PACKAGE url hash name local_url )
  IF(NOT MT_PACKAGES_PATH STREQUAL "")
    SET(DST "${MT_PACKAGES_PATH}/${name}")
    STRING(LENGTH "${hash}" _hash_length)
    IF(_hash_length EQUAL 64)
      file(DOWNLOAD "${url}" "${DST}" EXPECTED_HASH "SHA256=${hash}" SHOW_PROGRESS )
    ELSE()
      file(DOWNLOAD "${url}" "${DST}" EXPECTED_MD5 "${hash}" SHOW_PROGRESS )
    ENDIF()
    SET(${local_url} "file://${DST}" PARENT_SCOPE)
  ELSE()
    # No cache directory. Hand back the original URL and let
    # ExternalProject_Add do the download and the hash check itself.
    SET(${local_url} "${url}" PARENT_SCOPE)
  ENDIF()
ENDFUNCTION(GET_PACKAGE)
