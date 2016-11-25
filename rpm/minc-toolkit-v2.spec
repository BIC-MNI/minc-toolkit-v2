#
# spec file for minc-toolkit-v2
#
Summary: minc toolkit version 2
Name: minc-toolkit-v2
Version: 1.9.11
Release: 1%{?dist}
Source0: https://github.com/BIC-MNI/%{name}/archive/%{version}/%{name}-%{version}.tar.gz
URL: http://bic-mni.github.io
Packager: Vladimir Fonov <vladimir.fonov@gmail.com>
License: GPL-2.0
Provides:       minc-toolkit-v2 = %{version}

%if 0%{?el6} || 0%{?el7}
BuildRequires: cmake3 >= 3.1
%else
BuildRequires:  cmake >= 3.1
%endif
BuildRequires:  bison
BuildRequires:  flex
BuildRequires:  libXi-devel
BuildRequires:  libXmu-devel
#BuildRequires:  libxmu-headers
BuildRequires:  bzip2
BuildRequires:  gcc-c++
BuildRequires:  git
BuildRequires:  mesa-libGL-devel
BuildRequires:  mesa-libGLU-devel
BuildRequires: libjpeg-turbo-devel

Prefix:         /opt/minc/%{version}
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%define debug_package %{nil}
%define _prefix /opt/minc/%{version}

%description
This is to be filled...


%prep
%setup -q -n minc-toolkit-v2-%{version}


%build
export CFLAGS="%{optflags}"
export CXXFLAGS="%{optflags}"

mkdir -p build
cd build
%if 0%{?el6} || 0%{?el7}
cmake3 .. \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=%{_prefix} \
    -DMT_BUILD_ABC:BOOL=ON \
    -DMT_BUILD_ANTS:BOOL=ON \
    -DMT_BUILD_C3D:BOOL=ON \
    -DMT_BUILD_ELASTIX:BOOL=ON \
    -DMT_BUILD_IM:BOOL=OFF \
    -DMT_BUILD_ITK_TOOLS:BOOL=ON \
    -DMT_BUILD_LITE:BOOL=OFF \
    -DMT_BUILD_SHARED_LIBS:BOOL=ON \
    -DMT_BUILD_VISUAL_TOOLS:BOOL=ON \
    -DMT_BUILD_QUIET:BOOL=ON \
    -DMT_USE_OPENMP:BOOL=ON \
    -DUSE_SYSTEM_FFTW3D:BOOL=OFF \
    -DUSE_SYSTEM_FFTW3F:BOOL=OFF \
    -DUSE_SYSTEM_GLUT:BOOL=OFF \
    -DUSE_SYSTEM_GSL:BOOL=OFF \
    -DUSE_SYSTEM_HDF5:BOOL=OFF \
    -DUSE_SYSTEM_ITK:BOOL=OFF \
    -DUSE_SYSTEM_NETCDF:BOOL=OFF \
    -DUSE_SYSTEM_NIFTI:BOOL=OFF \
    -DUSE_SYSTEM_PCRE:BOOL=OFF \
    -DUSE_SYSTEM_ZLIB:BOOL=OFF
%else
cmake .. \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:PATH=%{_prefix} \
    -DMT_BUILD_ABC:BOOL=ON \
    -DMT_BUILD_ANTS:BOOL=ON \
    -DMT_BUILD_C3D:BOOL=ON \
    -DMT_BUILD_ELASTIX:BOOL=ON \
    -DMT_BUILD_IM:BOOL=OFF \
    -DMT_BUILD_ITK_TOOLS:BOOL=ON \
    -DMT_BUILD_LITE:BOOL=OFF \
    -DMT_BUILD_SHARED_LIBS:BOOL=ON \
    -DMT_BUILD_VISUAL_TOOLS:BOOL=ON \
    -DMT_BUILD_QUIET:BOOL=ON \
    -DMT_USE_OPENMP:BOOL=ON \
    -DUSE_SYSTEM_FFTW3D:BOOL=OFF \
    -DUSE_SYSTEM_FFTW3F:BOOL=OFF \
    -DUSE_SYSTEM_GLUT:BOOL=OFF \
    -DUSE_SYSTEM_GSL:BOOL=OFF \
    -DUSE_SYSTEM_HDF5:BOOL=OFF \
    -DUSE_SYSTEM_ITK:BOOL=OFF \
    -DUSE_SYSTEM_NETCDF:BOOL=OFF \
    -DUSE_SYSTEM_NIFTI:BOOL=OFF \
    -DUSE_SYSTEM_PCRE:BOOL=OFF \
    -DUSE_SYSTEM_ZLIB:BOOL=OFF
%endif

make %{?_smp_mflags}


%install
cd build
make install DESTDIR=%{buildroot} %{?_smp_mflags}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%{_prefix}/*

%changelog
