# install third party perl modules

# tweak to help testing
add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/Getopt/Tabular.pm
  COMMAND mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/Getopt
  COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/Getopt-Tabular-0.3/Tabular.pm ${CMAKE_CURRENT_BINARY_DIR}/Getopt/
)

add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/Text/Format.pm
  COMMAND mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/Text
  COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/Text-Format-0.53/lib/Text/Format.pm ${CMAKE_CURRENT_BINARY_DIR}/Text/
)

add_custom_target(copy_perl_modules ALL echo 
       DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/Getopt/Tabular.pm ${CMAKE_CURRENT_BINARY_DIR}/Text/Format.pm
                 )

# install Getopt::Tabular
INSTALL(FILES 
   Getopt-Tabular-0.3/Tabular.pm
  DESTINATION 
   perl/Getopt)

INSTALL(FILES 
   Text-Format-0.53/lib/Text/Format.pm
  DESTINATION 
   perl/Text)

