Summary: Medical Imaging NetCDF Toolkit, bundle of MINC-based softwares.
Name: minc-toolkit
Version: 0.3.6
Release: 2
License: GPL
Source: minc-toolkit-%{version}.tar.bz2
Patch0: minc-toolkit_cmake-modules_FindNETPBM.patch
Patch1: minc-toolkit_bicpl_Images_rgb_io_ppm.patch
Patch2: minc-toolkit_minc-toolkit-config.unix.csh.cmake.patch
Patch3: minc-toolkit_minc-toolkit-config.unix.sh.cmake.patch
# Fix a stupid RPM perl dependency check
Patch4: minc-toolkit_mni_autoreg_perl_mritoself.in.patch
# Disable Display
Patch5: minc-toolkit_CMakeLists.patch
BuildRoot: /var/tmp/%{name}-root
URL: git://github.com/vfonov/minc-toolkit.git
BuildRequires: netcdf-devel, hdf5-devel, freeglut-devel, pcre-devel, libXmu-devel, gsl-devel, fftw-devel

%define _prefix /opt/%{name}/%{version}


%description
This metaproject is designed to bundle together various related MINC-based packages which historically have been developed in a semi-independent way:
 * minc - base Medical Imaging NetCDF package, file IO library, low-level image manipulation tools
 * bicpl - BIC programming library, adds supports for 3D objects in terms of io-library and low-level tools
 * EBTKS - Everything but the kitchen sink library, higher level C++ library for image manipulation
 * arguments - helper library for parsin command line arguments 
 * oobicpl - Object Oriented BIC programming library, provides higher level C++ interface to bicpl, and some higher level object manipulation tools
 * conglomerate - conglomerate of low-level volume and object manipilation tools
 * inormalize - intensity normalization tools
 * N3 - non-parametric method for correction of intensity non-uniformity in MRI data (http://en.wikibooks.org/wiki/MINC/Tools/N3)
 * classify - Tissue classification tools
 * mni_autoreg - MNI Automated Registration Package, supports both linear and non-linear registration, implements ANIMAL algorithm
 * ray_trace - 3D visualisation tool 
 * EZminc -  Eazy MINC - higher level C++ interface to minc, includes distortion correction tool, non-local means filter, markov random field tissue classification tool, modified diffeomorphic demons non-linear registration tool

%prep
%setup -q
%patch0
%patch1
%patch2
%patch3
%patch4
%patch5

%build
mkdir build
pushd build
%cmake .. \
-DCMAKE_BUILD_TYPE=Release \
-DMT_BUILD_SHARED_LIBS:BOOL=ON \
-DBUILD_SHARED_LIBS:BOOL=OFF \
-DUSE_SYSTEM_ZLIB:BOOL=ON \
-DUSE_SYSTEM_NETCDF:BOOL=ON \
-DUSE_SYSTEM_HDF5:BOOL=ON \
-DUSE_SYSTEM_PCRE:BOOL=ON \
-DUSE_SYSTEM_GSL:BOOL=ON \
-DUSE_SYSTEM_FFTW3F:BOOL=ON \
-DUSE_SYSTEM_ITK:BOOL=ON \
-DBUILD_ITK_TOOLS:BOOL=ON \
-DBUILD_VISUAL_TOOLS:BOOL=ON \
-DITK_DIR=/usr/%{_lib}
make %{?_smp_mflags}
popd

%check
pushd build
make test
popd

%install
rm -rf $RPM_BUILD_ROOT
pushd build
make install DESTDIR=%{buildroot}

# Make sure to lib64
#%if "%{?_lib}" == "lib64" 
#    mv %{buildroot}%{_prefix}/lib %{buildroot}%{_prefix}/lib64
#%endif 

# Create /etc
mv %{buildroot}%{_prefix}/etc %{buildroot}
mkdir -p %{buildroot}%{_sysconfdir}/profile.d
mv %{buildroot}%{_prefix}/minc-toolkit-config.sh %{buildroot}%{_sysconfdir}/profile.d/
mv %{buildroot}%{_prefix}/minc-toolkit-config.csh %{buildroot}%{_sysconfdir}/profile.d/
popd
pushd %{buildroot}

# Locate all the files and store them in file.list
find . -type f | sed -e 's,^\.,\%attr(-\,root\,root) ,' \
-e '/\/etc\//s|^|%config|' \
  -e '/\/config\//s|^|%config|' > \
  $RPM_BUILD_DIR/file.list.%{name}

find . -type l | sed -e 's,^\.,\%attr(-\,root\,root) ,' >> \
  $RPM_BUILD_DIR/file.list.%{name}
popd 

%clean
rm -rf %{buildroot}

%files -f ../file.list.%{name}
# set perms and ownerships of packaged files
# the - indicates that the current permissions on the files should be used


%changelog
* Mon Apr 23 2012 Haz-Edine Assemlal <hassemlal@neurorx.com> 0.3.6-2
- change the prefix from /usr to /usr/local

* Mon Apr 23 2012 Haz-Edine Assemlal <hassemlal@neurorx.com> 0.3.6
- update to the most recent version of minc-toolkit

* Wed Mar 28 2012 Haz-Edine Assemlal <hassemlal@neurorx.com> 0.3.2
- add patch to fix compilation in MINC library
