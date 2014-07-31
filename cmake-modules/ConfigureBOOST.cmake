message("Configuring BOOST SOURCE_DIR=${SOURCE_DIR} BINARY_DIR=${BINARY_DIR}")

configure_file(${SOURCE_DIR}/cmake-modules/run_boost_config.sh.cmake ${BINARY_DIR}/BOOST/configure_boost.sh @ONLY)
