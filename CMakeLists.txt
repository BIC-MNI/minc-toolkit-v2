find_program(CCACHE_FOUND ccache)
if(CCACHE_FOUND)
    set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ${CCACHE_FOUND})
    set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK    ${CCACHE_FOUND})
endif(CCACHE_FOUND)

project(minc-toolkit-v2 )

enable_language(C)
enable_language(CXX)
#enable_language(Fortran)

cmake_minimum_required(VERSION 3.14) # for ITKv5

#Turn on PIC (and PIE if supported)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)


IF(COMMAND CMAKE_POLICY)
  IF(POLICY CMP0026)
      CMAKE_POLICY(SET CMP0026 NEW)
  ENDIF(POLICY CMP0026)
  IF(POLICY CMP0046)
      CMAKE_POLICY(SET CMP0046 NEW)
  ENDIF(POLICY CMP0046)
  if(POLICY CMP0083)
    cmake_policy(SET CMP0083 NEW)
  endif()
  if(POLICY CMP0135)
    cmake_policy(SET CMP0135 OLD)
  endif()
ENDIF(COMMAND CMAKE_POLICY)

SET(CMAKE_CXX_STANDARD 17)
SET(CMAKE_C_STANDARD 99)


SET(MINC_TOOLKIT_PACKAGE_VERSION_MAJOR 1)
SET(MINC_TOOLKIT_PACKAGE_VERSION_MINOR 9)
SET(MINC_TOOLKIT_PACKAGE_VERSION_PATCH 19)
SET(MINC_TOOLKIT_RELEASE_DATE "20211022")

SET(MINC_TOOLKIT_VERSION_FULL "${MINC_TOOLKIT_PACKAGE_VERSION_MAJOR}.${MINC_TOOLKIT_PACKAGE_VERSION_MINOR}.${MINC_TOOLKIT_PACKAGE_VERSION_PATCH}-${MINC_TOOLKIT_RELEASE_DATE}")

#SET(CPACK_GENERATOR DEB)
SET(CPACK_PACKAGE_NAME "minc-toolkit-v2")
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "minc image processing toolkit")
SET(CPACK_PACKAGE_VENDOR "Brain Imaging Center, Montreal Neurological Institute, McGill University")
SET(CPACK_PACKAGE_VERSION_MAJOR ${MINC_TOOLKIT_PACKAGE_VERSION_MAJOR})
SET(CPACK_PACKAGE_VERSION_MINOR ${MINC_TOOLKIT_PACKAGE_VERSION_MINOR})
SET(CPACK_PACKAGE_VERSION_PATCH ${MINC_TOOLKIT_PACKAGE_VERSION_PATCH})
SET(CPACK_PACKAGE_CONTACT "Vladimir Fonov <vladmir.fonov@gmail.com>")
SET(CPACK_PACKAGE_INSTALL_DIRECTORY "minc-toolkit-${MINC_TOOLKIT_VERSION_FULL}")
SET(CPACK_MONOLITHIC_INSTALL ON)
SET(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_SOURCE_DIR}/README.md")
SET(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/COPYING.txt")
SET(CPACK_PACKAGE_RELOCATABLE OFF)

#IF (CMAKE_SYSTEM_PROCESSOR MATCHES "unknown")
EXEC_PROGRAM(uname ARGS "-m" OUTPUT_VARIABLE CMAKE_SYSTEM_PROCESSOR)
#ENDIF (CMAKE_SYSTEM_PROCESSOR MATCHES "unknown")

IF(NOT DEFINED CPACK_SYSTEM_NAME)
  SET(MT_SYSTEM_NAME ${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR})
ENDIF(NOT DEFINED CPACK_SYSTEM_NAME)

IF(${CMAKE_SYSTEM_NAME} MATCHES Windows)
  IF(CMAKE_CL_64)
    SET(MT_SYSTEM_NAME win64-${CMAKE_SYSTEM_PROCESSOR})
  ELSE(CMAKE_CL_64)
    SET(MT_SYSTEM_NAME win32-${CMAKE_SYSTEM_PROCESSOR})
  ENDIF(CMAKE_CL_64)
ELSE(${CMAKE_SYSTEM_NAME} MATCHES Windows)
  IF(${CMAKE_SYSTEM_NAME} MATCHES Linux )
    # lsb_release is not installed on modern Fedora (the lsb packages were
    # dropped in Fedora 35+); without this guard its "command not found"
    # output leaks slashes into CPACK_PACKAGE_FILE_NAME and breaks cpack.
    FIND_PROGRAM(LSB_RELEASE_EXECUTABLE lsb_release)
    IF(LSB_RELEASE_EXECUTABLE)
      EXEC_PROGRAM(${LSB_RELEASE_EXECUTABLE} ARGS "-s -i" OUTPUT_VARIABLE SYSTEM_ID)
      EXEC_PROGRAM(${LSB_RELEASE_EXECUTABLE} ARGS "-s -r" OUTPUT_VARIABLE SYSTEM_RELEASE)
      SET(MT_SYSTEM_NAME "${SYSTEM_ID}_${SYSTEM_RELEASE}-${CMAKE_SYSTEM_PROCESSOR}")
    ELSE()
      SET(MT_SYSTEM_NAME "${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}")
    ENDIF()
  ENDIF(${CMAKE_SYSTEM_NAME} MATCHES Linux )
ENDIF(${CMAKE_SYSTEM_NAME} MATCHES Windows)

IF( NOT CMAKE_BUILD_TYPE )
   message("Build type is not set, setting to Release!")
   SET( CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel." FORCE )
ENDIF()

# Cap C++ at gnu++17. This vintage codebase and its pinned ITK use
# constructs removed in C++20 -- notably std::allocator::rebind, dropped from
# libstdc++ 15+, which breaks downstream consumers of ITK's KWSys hash_map
# (Convert3D etc.) on compilers that now default to C++20 (GCC 15/16). C++17
# still provides them. Components forward ${CMAKE_CXX_FLAGS} to their
# ExternalProjects, so this reaches every consumer; ITK keeps its own internal
# standard. Matches the existing -std=gnu17 handling for C.
#
# These are GCC/Clang flag spellings; MSVC and clang-cl use /std: and reject
# -std= / -Wno-register. Windows/MSVC is not a supported build target (Linux and
# macOS only), but guard on NOT MSVC so a stray MSVC configure does not error.
IF(NOT MSVC)
  IF(NOT CMAKE_CXX_FLAGS MATCHES "-std=")
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=gnu++17")
  ENDIF()

  # The 'register' storage-class keyword was removed in C++17. Vintage vendored
  # code still uses it (e.g. Elastix's ANN/ann_1.1). clang makes this a hard
  # error at C++17 ([-Wregister]); gcc only warns (so Linux built). Downgrade it
  # everywhere so the C++17 cap doesn't break this code on clang/macOS.
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-register")
ENDIF()

# At C++17 std::unary_function/binary_function (and other C++17-removed cruft)
# are gone. libstdc++ still ships them as deprecated, but macOS libc++ removes
# them, so ITK's KWSys hash_map (used by Convert3D/Elastix) fails to compile
# ("no template named 'unary_function' in namespace 'std'"). Re-enable the
# removed features on libc++ via its escape-hatch macros. No-op on libstdc++.
IF(APPLE)
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_LIBCPP_ENABLE_CXX17_REMOVED_FEATURES -D_LIBCPP_ENABLE_CXX17_REMOVED_UNARY_BINARY_FUNCTION")
ENDIF()

SET(CPACK_PACKAGE_FILE_NAME "minc-toolkit-${MINC_TOOLKIT_VERSION_FULL}-${MT_SYSTEM_NAME}")

# register local modules
SET(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" "${CMAKE_SOURCE_DIR}/cmake-modules")

INCLUDE(PreventInSourceBuilds)
AssureOutOfSourceBuilds(minc-toolkit-v2)
# a hack to disable internal man pages per project
SET(DISABLE_MAN_PAGES_INSTALL ON)
INCLUDE(InstallManPages)
INCLUDE(DownloadPackage)

# default install directories
SET(CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_BINARY_DIR} CACHE PATH "Install path prefix, prepended onto install directories.")
SET(CPACK_SET_DESTDIR    ON)
SET(CPACK_PACKAGING_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})
SET(CPACK_STRIP_FILES    ON)

# MAC OS X magick
SET(MACOSX_RPATH  ON)
SET(CMAKE_INSTALL_RPATH ${CMAKE_INSTALL_PREFIX}/lib${LIB_SUFFIX})
SET(CMAKE_SKIP_RPATH OFF)
SET(CMAKE_SKIP_INSTALL_RPATH OFF)
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE)

# superbuild options
OPTION(MT_BUILD_LITE         "Build lite version of minc-toolkit, without ITK or visual tools" OFF)
OPTION(MT_BUILD_SHARED_LIBS  "Build shared libraries." OFF)
OPTION(USE_SYSTEM_ZLIB       "Use System ZLIB "       OFF)
#OPTION(USE_SYSTEM_NIFTI      "Use System NIFTI "       OFF)
#OPTION(USE_SYSTEM_GIFTI      "Use System GIfTI"       OFF)
OPTION(USE_SYSTEM_NETCDF     "Use System NETCDF > 3.6.3" OFF)
OPTION(USE_SYSTEM_HDF5       "Use System HDF5 > 1.8"     OFF)
OPTION(USE_SYSTEM_GSL        "Use System GSL "         OFF)
OPTION(USE_SYSTEM_FFTW3F     "Use System FFTW3F "      OFF)
OPTION(USE_SYSTEM_FFTW3D     "Use System FFTW3D "      OFF)
OPTION(USE_SYSTEM_GLUT       "Use System GLUT  "       ON)
OPTION(USE_SYSTEM_OPENJPEG   "Use System OpenJPEG  "   OFF)
OPTION(USE_SYSTEM_JPEG       "Use System JPEG  "   OFF)
OPTION(USE_SYSTEM_LIBARCHIVE  "Use System LIBARCHIVE " OFF)

OPTION(MT_BUILD_ITK_TOOLS    "Build ITK-based tools"  ON)
OPTION(MT_BUILD_VISUAL_TOOLS "Build visual tools (Display, Register, postf, ray_trace) requires OpenGL & Glut"  OFF)
# GLUT is deprecated on macOS (and freeglut is fragile to build there); use
# bicgl's GLFW/native-Cocoa windowing backend instead when building on Apple.
OPTION(MT_USE_GLFW           "Use GLFW for visual tools instead of GLUT" ${APPLE})
# On Apple, GLUT/freeglut is not supported; always use the GLFW backend.
IF(APPLE AND NOT MT_USE_GLFW)
  MESSAGE(STATUS "Forcing MT_USE_GLFW=ON on Apple (GLUT/freeglut unsupported)")
  SET(MT_USE_GLFW ON CACHE BOOL "Use GLFW for visual tools instead of GLUT" FORCE)
ENDIF()

OPTION(USE_SYSTEM_ITK        "Use System ITK" OFF)
OPTION(MT_USE_OPENMP         "Use OpenMP multi-threading" OFF)
OPTION(MT_USE_BLAS           "Use BLAS for linear algebra")
#OPTION(MT_USE_OPENMP_BLAS    "Use Build OpenBLAS with OpenMP support" OFF) # TODO: finish this to compile on some platforms

OPTION(MNI_AUTOREG_OLD_AMOEBA_INIT "Use legacy version of the code to initialize AMOEBA in minctracc" OFF)

SET(MT_PACKAGES_PATH "${CMAKE_BINARY_DIR}/cache" CACHE PATH  "Directory containing 3rd party packages")

IF(APPLE)
  SET(MT_APPLE_ARCH "${CMAKE_SYSTEM_PROCESSOR}"  CACHE STRING "Build for this Apple arch" FORCE  )
ENDIF(APPLE)

IF(MT_BUILD_LITE)
  SET(MT_BUILD_ITK_TOOLS    OFF)
  SET(MT_BUILD_VISUAL_TOOLS OFF)
  SET(MT_BUILD_ANTS         OFF)
  SET(MT_BUILD_C3D          OFF)
  SET(MT_BUILD_ELASTIX      OFF)

  SET(CPACK_PACKAGE_FILE_NAME "minc-toolkit-${MINC_TOOLKIT_VERSION_FULL}-${MT_SYSTEM_NAME}-lite")
ENDIF(MT_BUILD_LITE)



ENABLE_TESTING()
INCLUDE(CTest)

# provide test environement
# CACHE INTERNAL FORCE
# for superbuild
SET(USE_SUPERBUILD ON)
INCLUDE(ExternalProject)
INCLUDE(ConfigureExternalProjects)
SET(SUPERBUILD_STAGING_PREFIX ${CMAKE_BINARY_DIR}/external)

# Fix missing share directory
file(MAKE_DIRECTORY ${SUPERBUILD_STAGING_PREFIX}/${CMAKE_INSTALL_PREFIX}/share)

SET(MINC_TEST_ENVIRONMENT
 "PATH=${CMAKE_CURRENT_BINARY_DIR}:${CMAKE_CURRENT_BINARY_DIR}/N3:${CMAKE_CURRENT_BINARY_DIR}/classify:${CMAKE_CURRENT_BINARY_DIR}/minctools/progs:${CMAKE_CURRENT_BINARY_DIR}/minctools/conversion:${CMAKE_CURRENT_BINARY_DIR}/mni_autoreg/mincblur:${CMAKE_CURRENT_BINARY_DIR}/mni_autoreg/make_phantom:${CMAKE_CURRENT_BINARY_DIR}/mni_autoreg/minctracc:${CMAKE_CURRENT_BINARY_DIR}/EZMINC-build/tools:${CMAKE_CURRENT_BINARY_DIR}/EZMINC-build/distortion_correction:${SUPERBUILD_STAGING_PREFIX}/${CMAKE_INSTALL_PREFIX}/bin:$ENV{PATH}"
)

LIST(APPEND MINC_TEST_ENVIRONMENT "PERL5LIB=${CMAKE_SOURCE_DIR}/mni-perllib:${CMAKE_CURRENT_BINARY_DIR}/mni-perllib/perl:${CMAKE_CURRENT_BINARY_DIR}/perl-modules:$ENV{PERL5LIB}")


IF(APPLE)
  LIST(APPEND MINC_TEST_ENVIRONMENT "DYLD_LIBRARY_PATH=${SUPERBUILD_STAGING_PREFIX}/${CMAKE_INSTALL_PREFIX}/lib${LIB_SUFFIX}:${CMAKE_CURRENT_BINARY_DIR}/libminc:${SUPERBUILD_STAGING_PREFIX}/${CMAKE_INSTALL_PREFIX}/lib${LIB_SUFFIX}:${CMAKE_CURRENT_BINARY_DIR}/libminc/ezminc:$ENV{DYLD_LIBRARY_PATH}")
ELSE(APPLE)
  LIST(APPEND MINC_TEST_ENVIRONMENT "LD_LIBRARY_PATH=${SUPERBUILD_STAGING_PREFIX}/${CMAKE_INSTALL_PREFIX}/lib${LIB_SUFFIX}:${CMAKE_CURRENT_BINARY_DIR}/libminc:${CMAKE_CURRENT_BINARY_DIR}/libminc/ezminc:$ENV{LD_LIBRARY_PATH}")
ENDIF(APPLE)

# ExternalProject_Add passes CMAKE_ARGS as a ;-separated list, so a multi-arch
# CMAKE_OSX_ARCHITECTURES such as "arm64;x86_64" gets split into two arguments
# and only the first reaches the sub-build -- leaving vendored dependencies
# single-arch and breaking the universal link. Re-encode it with the ::: list
# separator (paired with LIST_SEPARATOR ::: in each ExternalProject_Add) so the
# full architecture list propagates.
IF(APPLE)
  STRING(REPLACE ";" ":::" CMAKE_OSX_ARCHITECTURES_EXTSEP "${CMAKE_OSX_ARCHITECTURES}")
ENDIF(APPLE)


# required packages
FIND_PACKAGE( Perl   REQUIRED )

# required for minc
IF(USE_SYSTEM_ZLIB)
  FIND_PACKAGE( ZLIB   REQUIRED )
ELSE()
  INCLUDE(BuildZLIB)
  build_zlib( ${CMAKE_INSTALL_PREFIX} ${SUPERBUILD_STAGING_PREFIX})
  # we should have ZLIB at this point
  SET(HAVE_ZLIB ON)
ENDIF()


IF(USE_SYSTEM_NETCDF)
  FIND_PACKAGE( NETCDF REQUIRED )
ELSE()
  INCLUDE(BuildNETCDF)
  build_netcdf( ${CMAKE_INSTALL_PREFIX} ${SUPERBUILD_STAGING_PREFIX})
ENDIF()


IF(USE_SYSTEM_HDF5)
  IF(MT_BUILD_ITK_TOOLS)
    # need to find more
    FIND_PACKAGE(HDF5 REQUIRED COMPONENTS C CXX HL)
  ELSE()
    FIND_PACKAGE(HDF5 REQUIRED )
  ENDIF()

  #HACK to make FIND_PACKAGE adn build_hdf5 compatible
  IF(NOT HDF5_LIBRARIES AND HDF5_LIBRARY)
    SET(HDF5_LIBRARIES    ${HDF5_LIBRARY})
  ENDIF()

ELSE()
  INCLUDE(BuildHDF5)
  build_hdf5( ${CMAKE_INSTALL_PREFIX} ${SUPERBUILD_STAGING_PREFIX})
  IF(NOT USE_SYSTEM_ZLIB)
    add_dependencies(HDF5 ZLIB)
  ENDIF()
ENDIF()

IF(USE_SYSTEM_NIFTI)
  FIND_PACKAGE(NIFTI REQUIRED)
ELSE()
  INCLUDE(BuildNIFTI)
  build_nifti( ${CMAKE_INSTALL_PREFIX} ${SUPERBUILD_STAGING_PREFIX})
  IF(NOT USE_SYSTEM_ZLIB)
    add_dependencies(NIFTI ZLIB)
  ENDIF()
ENDIF()

# IF(USE_SYSTEM_GIFTI)
#   FIND_PACKAGE( GIFTI OPTIONAL )
# ELSE(USE_SYSTEM_GIFTI)
#   INCLUDE(BuildGIFTI)
#   build_gifti( ${CMAKE_INSTALL_PREFIX} ${SUPERBUILD_STAGING_PREFIX})
#   IF(NOT USE_SYSTEM_NIFTI)
#     add_dependencies(GIFTI NIFTI)
#   ENDIF(NOT USE_SYSTEM_NIFTI)
# ENDIF(USE_SYSTEM_GIFTI)

# for minctools (dcm2mnc)
IF(USE_SYSTEM_OPENJPEG)
  FIND_PACKAGE( OpenJPEG )
ELSE()
  INCLUDE(BuildOpenJPEG)
  build_openjpeg( ${CMAKE_INSTALL_PREFIX} ${SUPERBUILD_STAGING_PREFIX})
ENDIF()

IF(USE_SYSTEM_JPEG)
  FIND_PACKAGE( JPEG )
ELSE()
  INCLUDE(BuildJPEG)
  build_jpeg( ${CMAKE_INSTALL_PREFIX} ${SUPERBUILD_STAGING_PREFIX})
ENDIF()

IF(USE_SYSTEM_LIBARCHIVE)
  FIND_PACKAGE( LibArchive QUIET )
ELSE()
  INCLUDE(BuildLibarchive)
  build_libarchive( ${CMAKE_INSTALL_PREFIX} ${SUPERBUILD_STAGING_PREFIX})
ENDIF()

#required for some minc tools
FIND_PACKAGE( BISON )
FIND_PACKAGE( FLEX )
FIND_PACKAGE( Threads )

#required for bicpl
IF( USE_SYSTEM_NETPBM ) # else we will use bundled libppm
  FIND_PACKAGE( NETPBM QUIET )
ENDIF( USE_SYSTEM_NETPBM )

# required for mni_autoreg
INCLUDE(BuildLIBLBFGS)
build_liblbfgs(${CMAKE_INSTALL_PREFIX} ${SUPERBUILD_STAGING_PREFIX})

SET(MINC_TOOLKIT_BUILD ON)
SET(MINC_TOOLKIT_BUILD_DIR   ${CMAKE_BINARY_DIR})
SET(MINC_TOOLKIT_INSTALL_DIR ${CMAKE_INSTALL_PREFIX})

#setup parameters
SET(LIBMINC_BUILD_V2           ON)
SET(LIBMINC_MINC1_SUPPORT      ON)
SET(LIBMINC_NIFTI_SUPPORT      ON)
SET(LIBMINC_FOUND              ON)
SET(LIBMINC_BUILD_TOOLS        ON)
SET(LIBMINC_BUILD_CONVERTERS   ON)
SET(LIBMINC_BUILD_EZMINC       ON)
SET(LIBMINC_BUILD_EZMINC_EXAMPLES ON)
SET(LIBMINC_INSTALL_BIN_DIR bin)
SET(LIBMINC_INSTALL_LIB_DIR lib${LIB_SUFFIX})
SET(LIBMINC_INSTALL_INCLUDE_DIR include)
SET(LIBMINC_INSTALL_DATA_DIR share)
SET(LIBMINC_INTEGRATE_VOLUME_IO OFF)
SET(LIBMINC_EXPORTED_TARGETS "LIBMINC-targets")
# we have both MINC1 API
SET(HAVE_MINC1 ON)
# and MINC2 API
SET(HAVE_MINC2 ON)

IF(MT_BUILD_SHARED_LIBS)
  SET(LIBMINC_BUILD_SHARED_LIBS    ON)
  #EBTKS
  SET(EBTKS_BUILD_SHARED_LIBS      ON)
  #bicpl
  SET(BICPL_BUILD_SHARED_LIBS      ON)
  #oobicpl
  SET(OOBICPL_BUILD_SHARED_LIBS    ON)
  #arguments
  SET(ARGUMENTS_BUILD_SHARED_LIBS  ON)
  #bicgl
  SET(BICGL_BUILD_SHARED_LIBS      OFF)
ELSE(MT_BUILD_SHARED_LIBS)
  SET(LIBMINC_BUILD_SHARED_LIBS    OFF)
  #EBTKS
  SET(EBTKS_BUILD_SHARED_LIBS      OFF)
  #bicpl
  SET(BICPL_BUILD_SHARED_LIBS      OFF)
  #oobicpl
  SET(OOBICPL_BUILD_SHARED_LIBS    OFF)
  #arguments
  SET(ARGUMENTS_BUILD_SHARED_LIBS  OFF)
  #bicgl
  SET(BICGL_BUILD_SHARED_LIBS      OFF)
ENDIF(MT_BUILD_SHARED_LIBS)


#EZMINC
SET(EZMINC_BUILD_MINCNLM  ON)
SET(EZMINC_BUILD_DISTORTION_CORRECTION  ON)
SET(EZMINC_BUILD_MRFSEG  ON)
SET(EZMINC_BUILD_DD      ON)
SET(EZMINC_BUILD_TOOLS   ON)

ADD_SUBDIRECTORY(libminc)

SET(MINC2_deps "")

IF(NOT USE_SYSTEM_NETCDF)
  SET(MINC2_deps ${MINC2_deps} NETCDF)
ENDIF(NOT USE_SYSTEM_NETCDF)

IF(NOT USE_SYSTEM_HDF5)
  SET(MINC2_deps ${MINC2_deps} HDF5)
ENDIF(NOT USE_SYSTEM_HDF5)

IF(NOT USE_SYSTEM_NIFTI)
  SET(MINC2_deps ${MINC2_deps} NIFTI)
ENDIF(NOT USE_SYSTEM_NIFTI)

# IF(NOT USE_SYSTEM_GIFTI)
#   SET(MINC2_deps ${MINC2_deps} GIFTI)
# ENDIF(NOT USE_SYSTEM_GIFTI)

IF(MINC2_deps)
  ADD_DEPENDENCIES(minc2 ${MINC2_deps})
ENDIF(MINC2_deps)

IF(MT_BUILD_SHARED_LIBS AND MINC2_deps)
  ADD_DEPENDENCIES(minc2_static  ${MINC2_deps})
ENDIF(MT_BUILD_SHARED_LIBS AND MINC2_deps)

# Setup main minc variables
SET(LIBMINC_USE_FILE ${CMAKE_BINARY_DIR}/libminc/UseLIBMINC.cmake CACHE INTERNAL "LIBMINC use file")
INCLUDE(${CMAKE_BINARY_DIR}/libminc/LIBMINCConfig.cmake)
INCLUDE(${LIBMINC_USE_FILE})

# The generated LIBMINCConfig.cmake sets LIBMINC_LIBRARIES / VOLUME_IO_LIBRARIES
# to absolute file paths (to avoid link-order issues in standalone builds).
# In the superbuild context, we need the actual CMake target name so that
# downstream targets (minctools, bicpl, etc.) inherit the correct include
# directories and build-order dependencies via target_link_libraries / LINK_LIBRARIES.
SET(LIBMINC_LIBRARIES        minc2)
SET(VOLUME_IO_LIBRARIES      minc2)
SET(LIBMINC_STATIC_LIBRARIES minc2)
SET(VOLUME_IO_STATIC_LIBRARIES minc2)
SET(EZMINC_LIBRARIES         minc_io minc2)

ADD_SUBDIRECTORY(minctools)

IF(NOT USE_SYSTEM_OPENJPEG)
  ADD_DEPENDENCIES(dcm2mnc  OPENJPEG)
ENDIF(NOT USE_SYSTEM_OPENJPEG)

IF(NOT USE_SYSTEM_JPEG)
  ADD_DEPENDENCIES(dcm2mnc  JPEG)
ENDIF(NOT USE_SYSTEM_JPEG)

IF(NOT USE_SYSTEM_LIBARCHIVE)
  ADD_DEPENDENCIES(dcm2mnc  LIBARCHIVE)
ENDIF(NOT USE_SYSTEM_LIBARCHIVE)


ADD_SUBDIRECTORY(minc-widgets)
ADD_SUBDIRECTORY(EBTKS)
ADD_DEPENDENCIES(EBTKS minc2)

# setup EBTKS variables
SET(EBTKS_USE_FILE ${CMAKE_BINARY_DIR}/EBTKS/UseEBTKS.cmake CACHE INTERNAL "EBTKS use file")
INCLUDE(${CMAKE_BINARY_DIR}/EBTKS/EBTKSConfig.cmake)
INCLUDE(${EBTKS_USE_FILE})

ADD_SUBDIRECTORY(bicpl)
#setup bicpl variables
SET(BICPL_USE_FILE ${CMAKE_BINARY_DIR}/bicpl/UseBICPL.cmake CACHE INTERNAL "BICPL use file")
INCLUDE(${CMAKE_BINARY_DIR}/bicpl/BICPLConfig.cmake)
INCLUDE(${BICPL_USE_FILE})
ADD_DEPENDENCIES(bicpl minc2)

ADD_SUBDIRECTORY(arguments)

#setup arguments variables
SET(ARGUMENTS_USE_FILE ${CMAKE_BINARY_DIR}/bicpl/UseARGUMENTS.cmake CACHE INTERNAL "ARGUMENTS use file")
INCLUDE(${CMAKE_BINARY_DIR}/arguments/ARGUMENTSConfig.cmake)
INCLUDE(${ARGUMENTS_USE_FILE})

ADD_SUBDIRECTORY(oobicpl)
ADD_DEPENDENCIES(oobicpl minc2 bicpl arguments)


#setup oobicpl variables
SET(OOBICPL_USE_FILE ${CMAKE_BINARY_DIR}/bicpl/UseOOBICPL.cmake CACHE INTERNAL "OOBICPL use file")
INCLUDE(${CMAKE_BINARY_DIR}/oobicpl/OOBICPLConfig.cmake)
INCLUDE(${OOBICPL_USE_FILE})

#ADD_SUBDIRECTORY(BEaST)
#ADD_SUBDIRECTORY(BEaST_library)
ADD_SUBDIRECTORY(conglomerate)
ADD_SUBDIRECTORY(classify)
ADD_SUBDIRECTORY(mni-perllib)
ADD_SUBDIRECTORY(N3)

ADD_SUBDIRECTORY(glim_image)
ADD_SUBDIRECTORY(mni_autoreg)

ADD_DEPENDENCIES(minctracc   LIBLBFGS)
ADD_DEPENDENCIES(mni_autoreg LIBLBFGS)
ADD_DEPENDENCIES(mni_autoreg mincresample)

ADD_SUBDIRECTORY(inormalize)
ADD_SUBDIRECTORY(mrisim)
ADD_SUBDIRECTORY(bic-pipelines)
ADD_SUBDIRECTORY(perl-modules)
ADD_SUBDIRECTORY(minc_gco)

# BLAS detection: single point that exports BLAS::BLAS for in-tree consumers
# and emits forwarding -D flags via blas_external_project_args() for ExternalProject
# children (BEAST, patch_morphology). When MT_BUILD_OPENBLAS=ON, BLASSourceBuild
# emits a marker; the actual OpenBLAS ExternalProject is wired below.
# When MT_USE_BLAS=OFF, BLASSetup short-circuits and creates empty stub targets;
# the MT_BUILD_OPENBLAS block below is also skipped (BLASSetup rejects that combo).
IF(MT_USE_BLAS AND MT_BUILD_OPENBLAS)
  enable_language(Fortran)
ENDIF()
include(${CMAKE_SOURCE_DIR}/cmake-modules/BLASSetup.cmake)
IF(MT_USE_BLAS AND MT_BUILD_OPENBLAS)
  include(BuildOpenBLAS)
  build_open_blas(${CMAKE_INSTALL_PREFIX} ${SUPERBUILD_STAGING_PREFIX} ${MT_USE_OPENMP})
  set(BLAS_LIBRARIES    "${OpenBLAS_LIBRARIES}")
  set(BLAS_INCLUDE_DIRS "${OpenBLAS_INCLUDE_DIRS}")
  set(BLAS_LINKER_FLAGS "")
  blas_create_target_shim("${OpenBLAS_LIBRARIES}" "" "${OpenBLAS_INCLUDE_DIRS}")
  # Source build was configured with -DLAPACKE=ON; the staged include dir
  # owns lapacke.h (materialised at make time, not configure time, so we
  # don't probe for it — we trust the build flag).
  set_property(TARGET LAPACKE::LAPACKE APPEND PROPERTY
    INTERFACE_INCLUDE_DIRECTORIES "${OpenBLAS_INCLUDE_DIRS}")
  set_property(TARGET LAPACKE::LAPACKE APPEND PROPERTY
    INTERFACE_COMPILE_DEFINITIONS "HAVE_LAPACKE")
ENDIF()

#required for EZminc
IF(USE_SYSTEM_GSL)
  FIND_PACKAGE(GSL)
ELSE(USE_SYSTEM_GSL)
  INCLUDE(BuildGSL)
  build_gsl(${CMAKE_INSTALL_PREFIX} ${SUPERBUILD_STAGING_PREFIX})
ENDIF(USE_SYSTEM_GSL)

IF(USE_SYSTEM_FFTW3F)
  INCLUDE(FindFFTW3F)
  FIND_PACKAGE(FFTW3F)
ELSE()
  INCLUDE(BuildFFTW3F)
  build_fftw3f(${CMAKE_INSTALL_PREFIX} ${SUPERBUILD_STAGING_PREFIX})
ENDIF()

IF(USE_SYSTEM_FFTW3D)
  INCLUDE(FindFFTW3)
  FIND_PACKAGE(FFTW3)
ELSE(USE_SYSTEM_FFTW3D)
  INCLUDE(BuildFFTW3D)
  build_fftw3d(${CMAKE_INSTALL_PREFIX} ${SUPERBUILD_STAGING_PREFIX})
ENDIF(USE_SYSTEM_FFTW3D)

# build tools that require ITK
IF(MT_BUILD_ITK_TOOLS)


  OPTION(MT_BUILD_ANTS     "Build ANTS " ON)
  OPTION(MT_BUILD_C3D      "Build convert3D " ON)

  OPTION(MT_BUILD_ELASTIX  "Build Elastix " ON)
  #OPTION(MT_BUILD_ABC      "Build ABC " OFF)
  # FOR Now old fork of Elastix doesn't work with ITKv5 
  # TODO: upgrade to the recent version of Elastix
  #SET(MT_BUILD_ELASTIX      OFF) 
  SET(MT_BUILD_ABC          OFF)


  IF(USE_SYSTEM_ITK)
    FIND_PACKAGE(ITK)
  ELSE(USE_SYSTEM_ITK)
    OPTION(USE_SYSTEM_EXPAT_ITK  "Use System expat for ITKv5  "   OFF)

    IF(USE_SYSTEM_EXPAT_ITK)
    FIND_PACKAGE(EXPAT REQUIRED)
    ENDIF()

    INCLUDE(BuildITKv5)

    build_itkv5(${CMAKE_INSTALL_PREFIX} ${SUPERBUILD_STAGING_PREFIX} ${CMAKE_BINARY_DIR}/libminc)

    # Setting dependecies
    ADD_DEPENDENCIES(ITKv5 minc2 )
    IF(NOT USE_SYSTEM_ZLIB)
        ADD_DEPENDENCIES(ITKv5 ZLIB)
    ENDIF()
    IF(NOT USE_SYSTEM_FFTW3D)
     ADD_DEPENDENCIES(ITKv5 FFTW3D)
    ENDIF()
    IF(NOT USE_SYSTEM_FFTW3F)
     ADD_DEPENDENCIES(ITKv5 FFTW3F)
    ENDIF()
    # TODO: allow using system lib?

    #
#    INCLUDE(BuildPNG)
#    build_png(${CMAKE_INSTALL_PREFIX} ${SUPERBUILD_STAGING_PREFIX})
#    ADD_DEPENDENCIES(ITKv4 PNG)
    
  ENDIF(USE_SYSTEM_ITK)

  IF(MT_BUILD_ANTS)
   INCLUDE(BuildANTS)
   #INCLUDE(BuildBOOST)
   #build_BOOST(${CMAKE_INSTALL_PREFIX} ${SUPERBUILD_STAGING_PREFIX})
   build_ANTS(${CMAKE_INSTALL_PREFIX} ${SUPERBUILD_STAGING_PREFIX} ${ITK_DIR} ) #${BOOST_DIR}
   ADD_DEPENDENCIES(ANTS ITKv5 minc2 ) #BOOST
  ENDIF(MT_BUILD_ANTS)

  IF(MT_BUILD_C3D)
   INCLUDE(BuildC3D)
   build_C3D(${CMAKE_INSTALL_PREFIX} ${SUPERBUILD_STAGING_PREFIX} ${ITK_DIR})
   ADD_DEPENDENCIES(C3D ITKv5 minc2)
  ENDIF(MT_BUILD_C3D)
  
  IF(MT_BUILD_ELASTIX)
   INCLUDE(BuildElastix)
   build_Elastix(${CMAKE_INSTALL_PREFIX} ${SUPERBUILD_STAGING_PREFIX} ${ITK_DIR})
   ADD_DEPENDENCIES(Elastix ITKv5 minc2)
  ENDIF(MT_BUILD_ELASTIX)

  INCLUDE(BuildEZMINC)
  build_EZMINC(${CMAKE_INSTALL_PREFIX} ${SUPERBUILD_STAGING_PREFIX} ${CMAKE_BINARY_DIR}/libminc ${CMAKE_BINARY_DIR}/bicpl ${ITK_DIR})
  ADD_DEPENDENCIES(EZMINC ITKv5 minc2 minc_io bicpl)
  
  IF(NOT USE_SYSTEM_GSL)
    ADD_DEPENDENCIES(EZMINC GSL)
  ENDIF()

  INCLUDE(BuildPatchMorphology)
  build_PatchMorphology(${CMAKE_INSTALL_PREFIX} ${SUPERBUILD_STAGING_PREFIX} ${ITK_DIR})
  ADD_DEPENDENCIES(patch_morphology ITKv5 minc_io)

  IF(MT_BUILD_OPENBLAS)
    ADD_DEPENDENCIES(patch_morphology OpenBLAS)
  ENDIF()


  IF(MT_BUILD_ABC)
   INCLUDE(BuildABC)
   build_ABC(${CMAKE_INSTALL_PREFIX} ${SUPERBUILD_STAGING_PREFIX} ${ITK_DIR})
   ADD_DEPENDENCIES(ABC ITKv5 minc2)
  ENDIF(MT_BUILD_ABC)
  
ENDIF(MT_BUILD_ITK_TOOLS)

# tools requiring OpenBLAS
INCLUDE(BuildBEAST)
build_BEAST(${CMAKE_INSTALL_PREFIX} ${SUPERBUILD_STAGING_PREFIX})
ADD_DEPENDENCIES(BEAST minc_io)

IF(MT_BUILD_OPENBLAS)
    ADD_DEPENDENCIES(BEAST OpenBLAS)
ENDIF()


# build tools that require OpenGL, and either GLUT or (via MT_USE_GLFW) GLFW
IF(MT_BUILD_VISUAL_TOOLS)
  FIND_PACKAGE( OpenGL REQUIRED )
  FIND_PACKAGE( X11    QUIET )

  IF(MT_USE_GLFW) # no need to use GLUT
    # bicgl's GLFW backend (native Cocoa on macOS) — no GLUT/freeglut needed.
    SET(BICGL_USE_GLFW ON CACHE BOOL "Build GLFW windowing backend (no GLX required)" FORCE)
    ADD_DEFINITIONS(-DBICGL_USE_GLFW=1)
  ELSE()
    IF(USE_SYSTEM_GLUT)
      FIND_PACKAGE( GLUT   REQUIRED )
    ELSE(USE_SYSTEM_GLUT)
      INCLUDE(BuildFREEGLUT) # newer version of build_freeglut seem to be causing problems
      build_freeglut( ${CMAKE_INSTALL_PREFIX} ${SUPERBUILD_STAGING_PREFIX})
    ENDIF(USE_SYSTEM_GLUT)
  ENDIF()

  ADD_SUBDIRECTORY(bicgl)
  INCLUDE(${CMAKE_BINARY_DIR}/bicgl/BICGLConfig.cmake)

  ADD_SUBDIRECTORY(ray_trace)
  ADD_SUBDIRECTORY(Display)
  ADD_SUBDIRECTORY(Register)
  ADD_SUBDIRECTORY(ILT)

  IF(NOT MT_USE_GLFW AND NOT USE_SYSTEM_GLUT)
    ADD_DEPENDENCIES(bicgl    FREEGLUT)
    ADD_DEPENDENCIES(register FREEGLUT)
    ADD_DEPENDENCIES(Display  FREEGLUT)
  ENDIF()

  IF(MT_BUILD_SHARED_LIBS)
    ADD_DEPENDENCIES(ray_trace bicgl minc2_static bicpl_static)
    ADD_DEPENDENCIES(Display   bicgl minc2_static bicpl_static)
    ADD_DEPENDENCIES(register  bicgl minc2_static bicpl_static)
  ELSE(MT_BUILD_SHARED_LIBS)
    ADD_DEPENDENCIES(ray_trace bicgl minc2 bicpl  )
    ADD_DEPENDENCIES(Display   bicgl minc2 bicpl  )
    ADD_DEPENDENCIES(register  bicgl minc2 bicpl  )
  ENDIF(MT_BUILD_SHARED_LIBS)

  IF(X11_FOUND)
    ADD_SUBDIRECTORY(postf)
    ADD_DEPENDENCIES(postf minc2)
    ADD_SUBDIRECTORY(xdisp)
    ADD_DEPENDENCIES(xdisp minc2)
  ENDIF(X11_FOUND)
ENDIF(MT_BUILD_VISUAL_TOOLS)

  #install external dependencies to final destination
INSTALL(DIRECTORY ${SUPERBUILD_STAGING_PREFIX}/${CMAKE_INSTALL_PREFIX}/bin
        DESTINATION .
        PATTERN *
        PERMISSIONS OWNER_EXECUTE OWNER_READ OWNER_WRITE GROUP_EXECUTE GROUP_READ WORLD_READ WORLD_EXECUTE )

INSTALL(DIRECTORY ${SUPERBUILD_STAGING_PREFIX}/${CMAKE_INSTALL_PREFIX}/lib${LIB_SUFFIX}
        DESTINATION .)

INSTALL(DIRECTORY ${SUPERBUILD_STAGING_PREFIX}/${CMAKE_INSTALL_PREFIX}/include
        DESTINATION .)

# share can be created by some packages
INSTALL(DIRECTORY ${SUPERBUILD_STAGING_PREFIX}/${CMAKE_INSTALL_PREFIX}/share
        DESTINATION .)


ADD_SUBDIRECTORY(man-pages)


# write configuration information
IF(UNIX)
  CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/minc-toolkit-config.unix.sh.cmake ${CMAKE_CURRENT_BINARY_DIR}/minc-toolkit-config.sh @ONLY)
  CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/minc-toolkit-config.unix.csh.cmake ${CMAKE_CURRENT_BINARY_DIR}/minc-toolkit-config.csh @ONLY)
ENDIF(UNIX)

IF(APPLE)
  CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/minc-toolkit-config.apple.sh.cmake ${CMAKE_CURRENT_BINARY_DIR}/minc-toolkit-config.sh @ONLY)
  CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/minc-toolkit-config.apple.csh.cmake ${CMAKE_CURRENT_BINARY_DIR}/minc-toolkit-config.csh @ONLY)
ENDIF(APPLE)

INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/minc-toolkit-config.sh ${CMAKE_CURRENT_BINARY_DIR}/minc-toolkit-config.csh DESTINATION .)

# setup additional variables for making Debian package
INCLUDE(DebianPackageAddons)

# setup additional variables for making RPM package
INCLUDE(RPMPackageAddons)


# according to http://www.cmake.org/pipermail/cmake/2011-November/047137.html it's better to put this in the end
INCLUDE(CPack)
