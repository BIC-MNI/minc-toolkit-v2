message("Running PatchITKv4")

macro(patch_itk_config file to_remove)
  file(READ "${file}" config_file)
  STRING(REPLACE "${to_remove}//" "/" config_file "${config_file}")
  STRING(REPLACE "${to_remove}" "" config_file "${config_file}")
  message("patched ${file} ")
  file(WRITE "${file}" "${config_file}")
endmacro(patch_itk_config)


FOREACH(conf "ITKTargets-release.cmake" "Modules/ITKZLIB.cmake" "Modules/ITKZLIB.cmake" "Modules/ITKMINC.cmake" "Modules/ITKHDF5.cmake" "Modules/ITKIOTransformMINC.cmake")
  if (EXISTS "${staging_prefix}/${install_prefix}/lib/cmake/ITK-4.9/${conf}")
    patch_itk_config("${staging_prefix}/${install_prefix}/lib/cmake/ITK-4.9/${conf}" "${staging_prefix}")
  endif()
ENDFOREACH(conf)


# a hack to remove internal minc directories
file(READ "${staging_prefix}/${install_prefix}/lib/cmake/ITK-4.9/Modules/ITKMINC.cmake" config_file)
STRING(REPLACE ";${minc_dir}/ezminc" "" config_file "${config_file}")
STRING(REPLACE "${CMAKE_CURRENT_BINARY_DIR}/ITKv4-build/Modules/ThirdParty/MINC/src;" "" config_file "${config_file}")
STRING(REPLACE "${minc_dir}" "${install_prefix}/lib" config_file "${config_file}")
STRING(REPLACE "${LIBMINC_INCLUDE_DIRS}" "${install_prefix}/include" config_file "${config_file}")
file(WRITE "${staging_prefix}/${install_prefix}/lib/cmake/ITK-4.9/Modules/ITKMINC.cmake" "${config_file}")

