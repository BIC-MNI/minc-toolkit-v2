# add_subdirectory consumer: BLAS::BLAS must be visible (IMPORTED GLOBAL).

if(NOT TARGET BLAS::BLAS)
  message(FATAL_ERROR "addsub_consumer: BLAS::BLAS not visible from add_subdirectory.")
endif()

add_executable(addsub_blas_link blas_link.c)
target_link_libraries(addsub_blas_link PRIVATE BLAS::BLAS)
