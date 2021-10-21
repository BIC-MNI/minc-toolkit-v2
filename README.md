# MINC - TOOLKIT (Medical Imaging NetCDF Toolkit)

## Introduction

This metaproject bundles multiple MINC-based packages that historically have been developed somewhat independently.

Here is a list of bundled packages:
 * zlib    - data compression library
 * NetCDF  - file format library ( used for MINC1)
 * HDF5    - another file format library  (used for MINC2)
 * FFTW    - FFT library
 * GSL     - Gnu Scientific library
 * openblas - fast library for linear algebra
 * ITK     - Insight Toolkti version 4.11
 * pcre    - perl-compatible regular expressions
 * libminc - base Medical Imaging NetCDF package, file IO library
 * minc-tools - low-level image manipulation tools
 * bicpl - BIC programming library, adds supports for 3D objects in terms of io-library and low-level tools
 * EBTKS - Everything But The Kitchen Sink library, higher level C++ library for image manipulation
 * arguments - helper library for parsing command line arguments 
 * oobicpl - Object Oriented BIC programming library, provides a higher level C++ interface to bicpl, 
      and some higher level object manipulation tools
 * conglomerate - conglomerate of low-level volume and object manipulation tools
 * inormalize - intensity normalization tools
 * N3 - non-parametric method for correction of intensity non-uniformity in MRI data (http://en.wikibooks.org/wiki/MINC/Tools/N3)
 * classify - Tissue classification tools
 * mni_autoreg - MNI Automated Registration Package, supports both linear and non-linear registration, implements ANIMAL algorithm
 * ray_trace - 3D visualisation tool 
 * glim_image - voxel-level general linar modelling tool
 * bic-pipelines - basic brain MRI processing pipeline
 * BEaST  - automatic brain extraction tool
 * mrisim  - MRI simulation tool
 * mni-perllib - perl library commonly used in perl scripts developed in BIC-MNI
 * EZminc -  Eazy MINC - higher level C++ interface to minc, includes distortion correction tool, non-local means filter, markov random field tissue classification tool, modified diffeomorphic demons non-linear registration tool
 * register - interactive 3D image viewer and co-registration tool
 * Display  - interactive 3D image viewer and segmentation tool
 * postf    - interactive 3D image viewer for statistical results
 * ITK      - Imaging Toolkit  https://itk.org/
 * c3d      - Convert3D multipurpose image processing tool from UPENN http://www.itksnap.org/c3d/
 * ANTS     - ANTS nonlinear registration tool from UPENN  https://github.com/stnava/ANTs
 * Elastix  - Elastix a toolbox for rigid and nonrigid registration of images. http://elastix.isi.uu.nl/ 

## Installation

### Installing from github, need CMake >= 3.1 
<pre><code>
  To get the latest supported version of minc-toolkit-v2 (1.9.18) 
  git clone --recursive --branch release-1.9.18 https://github.com/BIC-MNI/minc-toolkit-v2.git minc-toolkit-v2
  cd minc-toolkit-v2
  mkdir build && cd build
  ccmake .. # Enter configuration details, recommend not to use any system-provided libraries that are included in minc-toolkit-v2
</code></pre>
Following command will configure build system to build all the tools and install them into `/opt/minc/1.9.17` on Linux 
<pre><code>
 cmake .. \
-DCMAKE_BUILD_TYPE:STRING=Release   \
-DCMAKE_INSTALL_PREFIX:PATH=/opt/minc/1.9.18 \
-DMT_BUILD_ABC:BOOL=ON   \
-DMT_BUILD_ANTS:BOOL=ON   \
-DMT_BUILD_C3D:BOOL=ON   \
-DMT_BUILD_ELASTIX:BOOL=ON   \
-DMT_BUILD_IM:BOOL=OFF   \
-DMT_BUILD_ITK_TOOLS:BOOL=ON   \
-DMT_BUILD_LITE:BOOL=OFF   \
-DMT_BUILD_SHARED_LIBS:BOOL=ON   \
-DMT_BUILD_VISUAL_TOOLS:BOOL=ON   \
-DMT_USE_OPENMP:BOOL=ON   \
-DUSE_SYSTEM_FFTW3D:BOOL=OFF   \
-DUSE_SYSTEM_FFTW3F:BOOL=OFF   \
-DUSE_SYSTEM_GLUT:BOOL=OFF   \
-DUSE_SYSTEM_GSL:BOOL=OFF   \
-DUSE_SYSTEM_HDF5:BOOL=OFF   \
-DUSE_SYSTEM_ITK:BOOL=OFF   \
-DUSE_SYSTEM_NETCDF:BOOL=OFF   \
-DUSE_SYSTEM_NIFTI:BOOL=OFF   \
-DUSE_SYSTEM_PCRE:BOOL=OFF   \
-DUSE_SYSTEM_ZLIB:BOOL=OFF 

make && make install

If you have installed minc-toolkit-v2 outside of the default installation ( i.e. changing DCMAKE_INSTALL_PREFIX:PATH within the build above).
source minc-toolkit-config.sh

</pre></code>
## Dependencies

### Following packages are needed to compile all tools:
 * Tools without GUI
   * cmake - https://cmake.org/
   * Perl  - http://www.perl.org/
   * BISON - http://www.gnu.org/software/bison/
   * FLEX  - http://flex.sf.net/
   * bc    - http://ftp.gnu.org/gnu/bc/ 
   * libjpeg or libjpeg-turbo
 * More packages for tools with GUI
   * X11  development libraries
   * libxi 
   * libxmu
   * libjpeg-dev
   * libgl
   * libglu

### Following packages are built internally :
 * zlib   - http://zlib.net/
 * NETCDF - http://www.unidata.ucar.edu/software/netcdf/
 * HDF5   - http://www.hdfgroup.org/HDF5/
 * PCRE   - http://www.pcre.org/
 * GSL    - http://www.gnu.org/software/gsl/
 * FFTW3  - http://www.fftw.org/
 * ITK 4.13- http://www.itk.org/
 * NIFTI  - http://niftilib.sourceforge.net/
 * OpenBLAS  - http://www.openblas.net/
 
### Installing Build Dependencies on Ubuntu:
<pre><code>
sudo apt-get install \
 build-essential g++ bc \
 cmake \
 bison flex \
 libx11-dev x11proto-core-dev \
 libxi6 libxi-dev \
 libxmu6 libxmu-dev libxmu-headers \
 libgl1-mesa-dev libglu1-mesa-dev \
 libjpeg-dev
</code></pre>

### Installing Build Dependencies on CentOS 7:
<pre><code>
yum groupinstall 'Development Tools'  && \
yum install libX11-devel libXmu-devel libXi-devel \
 mesa-libGL-devel mesa-libGLU-devel \
 libjpeg-turbo-devel \
 openssl-devel bc \
 rpm-build-libs rpm-devel redhat-lsb-core
</code></pre>
