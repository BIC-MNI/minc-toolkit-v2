# download and install anatomical templates

SET(MNI_ICBM152_09C_URL "http://www.bic.mni.mcgill.ca/~vfonov/icbm/2009/mni_icbm152_nlin_sym_09c_minc2.zip")

SET(MNI_ICBM152_TEMPLATE 
  ${CMAKE_CURRENT_BINARY_DIR}/mni_icbm152_09c/COPYING
  ${CMAKE_CURRENT_BINARY_DIR}/mni_icbm152_09c/mni_icbm152_csf_tal_nlin_sym_09c.mnc
  ${CMAKE_CURRENT_BINARY_DIR}/mni_icbm152_09c/mni_icbm152_gm_tal_nlin_sym_09c.mnc
  ${CMAKE_CURRENT_BINARY_DIR}/mni_icbm152_09c/mni_icbm152_pd_tal_nlin_sym_09c.mnc
  ${CMAKE_CURRENT_BINARY_DIR}/mni_icbm152_09c/mni_icbm152_t1_tal_nlin_sym_09c_eye_mask.mnc
  ${CMAKE_CURRENT_BINARY_DIR}/mni_icbm152_09c/mni_icbm152_t1_tal_nlin_sym_09c_face_mask.mnc
  ${CMAKE_CURRENT_BINARY_DIR}/mni_icbm152_09c/mni_icbm152_t1_tal_nlin_sym_09c_mask.mnc
  ${CMAKE_CURRENT_BINARY_DIR}/mni_icbm152_09c/mni_icbm152_t1_tal_nlin_sym_09c.mnc
  ${CMAKE_CURRENT_BINARY_DIR}/mni_icbm152_09c/mni_icbm152_t2_tal_nlin_sym_09c.mnc
  ${CMAKE_CURRENT_BINARY_DIR}/mni_icbm152_09c/mni_icbm152_wm_tal_nlin_sym_09c.mnc
) 

SET(MNI_ICBM152_ATLAS 
  ${CMAKE_CURRENT_BINARY_DIR}/mni_icbm152_09c/mni_icbm152_t1_tal_nlin_sym_09c_atlas/atlas_csf.mnc
  ${CMAKE_CURRENT_BINARY_DIR}/mni_icbm152_09c/mni_icbm152_t1_tal_nlin_sym_09c_atlas/AtlasGrey.mnc
  ${CMAKE_CURRENT_BINARY_DIR}/mni_icbm152_09c/mni_icbm152_t1_tal_nlin_sym_09c_atlas/atlas_level0.5_BG.mnc
  ${CMAKE_CURRENT_BINARY_DIR}/mni_icbm152_09c/mni_icbm152_t1_tal_nlin_sym_09c_atlas/AtlasWhite.mnc
  ${CMAKE_CURRENT_BINARY_DIR}/mni_icbm152_09c/mni_icbm152_t1_tal_nlin_sym_09c_atlas/limits_grey.tag
  ${CMAKE_CURRENT_BINARY_DIR}/mni_icbm152_09c/mni_icbm152_t1_tal_nlin_sym_09c_atlas/limits_level0.5_BG.tag
  ${CMAKE_CURRENT_BINARY_DIR}/mni_icbm152_09c/mni_icbm152_t1_tal_nlin_sym_09c_atlas/limits_ven_manual.tag
)

function(DOWNLOAD_TEMPLATE url md5 dst )
  file(DOWNLOAD "${url}" "${dst}"  EXPECTED_MD5  "${md5}" SHOW_PROGRESS )
ENDFUNCTION(DOWNLOAD_TEMPLATE)

DOWNLOAD_TEMPLATE(${MNI_ICBM152_09C_URL} 
 "dcaa4de940a9ec5028e63ee5b3699b48" 
 "${CMAKE_CURRENT_BINARY_DIR}/mni_icbm152_nlin_sym_09c_minc2.zip"  )


add_custom_target( 
   unpack_mni_icbm152_09c ALL
   unzip -f -o ${CMAKE_CURRENT_BINARY_DIR}/mni_icbm152_nlin_sym_09c_minc2.zip -d ${CMAKE_CURRENT_BINARY_DIR}/mni_icbm152_09c
  DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/mni_icbm152_nlin_sym_09c_minc2.zip
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  COMMENT "Unpacking mni_icbm152_09c" VERBATIM
)

INSTALL(FILES 
    ${MNI_ICBM152_TEMPLATE}
 DESTINATION 
    share/icbm152_model_09c)

INSTALL(FILES 
    ${MNI_ICBM152_ATLAS}
 DESTINATION 
    share/icbm152_model_09c/mni_icbm152_t1_tal_nlin_sym_09c_atlas)
