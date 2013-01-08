# MINC - TOOLKIT (Medical Imaging NetCDF Toolkit)

## Introduction

This metaproject bundles multiple MINC-based packages that historically have been developed somewhat independently.

Here is a list of bundled packages:
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
 * ITK      - Imaging Tookkit
 * minc4itk - MINC to ITK glue library
 * c3d      - Convert3D multipurpose image processing tool from UPENN
 * mincANTS - ANTS nonlinear registration tool from UPENN

##Installation

Installing from github, need CMake > 2.6 , preferably > 2.8.3 
=======
<pre><code>
  git clone --recursive git://github.com/BIC-MNI/minc-toolkit.git minc-toolkit
  cd minc-toolkit
  mkdir build && cd build
  ccmake .. # Enter the location of all dependencies, if not detected automatically ...
  make && make test && make install
</code></pre>

##Dependencies

###Following packages are needed to compile all tools:
 * Perl  - http://www.perl.org/
 * BISON - http://www.gnu.org/software/bison/
 * FLEX  - http://flex.sf.net/
 * GLUT  - http://freeglut.sourceforge.net/
 * libxi   
 * libxmu 

###Following packages are optional (i.e thay can be build as part of superbuild)
 * zlib   - http://zlib.net/                                http://zlib.net/zlib-1.2.6.tar.gz
 * NETCDF - http://www.unidata.ucar.edu/software/netcdf/    ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.0.1.tar.gz
 * HDF5   - http://www.hdfgroup.org/HDF5/                   http://www.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8.8/src/hdf5-1.8.8.tar.gz
 * PCRE   - http://www.pcre.org/                            http://downloads.sourceforge.net/project/pcre/pcre/8.12/pcre-8.12.tar.gz
 * GSL    - http://www.gnu.org/software/gsl/                ftp://ftp.gnu.org/gnu/gsl/gsl-1.15.tar.gz
 * FFTW3  - http://www.fftw.org/                            http://www.fftw.org/fftw-3.3.2.tar.gz
 
##Installing Dependencies on Ubuntu 10.04, 12.04
<pre><code>
sudo apt-get install \
 build-essential g++ \
 cmake cmake-curses-gui \
 bison flex \
 freeglut3 freeglut3-dev \
 libxi6 libxi-dev libxmu6 libxmu-dev libxmu-headers
</code></pre>
