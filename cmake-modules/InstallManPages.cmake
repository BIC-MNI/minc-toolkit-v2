# install a list of files with names like XXXX.manY into install_prefi/manY/XXXX.Y

macro(INSTALL_MAN_PAGES install_prefix  )
  set(argn "${ARGN}")
  
  foreach(i IN LISTS argn)
    get_filename_component(fname ${i} NAME_WE)
    get_filename_component(fext ${i}  EXT)
    STRING(REGEX REPLACE ".man" "" SECTION ${fext})
    
    #TODO: add gzip compression
    INSTALL(FILES ${i} DESTINATION ${install_prefix}/man${SECTION}/ RENAME ${fname}.${SECTION})
    
  endforeach()
  
endmacro(INSTALL_MAN_PAGES )
