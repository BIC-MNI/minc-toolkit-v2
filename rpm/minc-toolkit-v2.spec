#
# spec file for minc-toolkit-v2
#
Summary: minc toolkit version 2
Name: minc-toolkit-v2
Version: 1.9.10
Release: 1
Group: XXX/XXX
Source: minc-toolkit-v2-1.9.10.tar.gz
URL: http://bic-mni.github.io
Packager: Vladimir Fonov <vladimir.fonov@gmail.com>
License: GPL-2.0
Provides:       minc-toolkit-v2 = %{version}

BuildRequires:  cmake
BuildRequires:  bison
BuildRequires:  flex
BuildRequires:  libXi-devel
BuildRequires:  libXmu-devel
#BuildRequires:  libxmu-headers
BuildRequires:  bzip2
BuildRequires:  gcc-c++
BuildRequires:  git
BuildRequires:  mesa-libGL-devel

Prefix:         /opt/minc/%{version}
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

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
    -DMT_USE_OPENMP:BOOL=ON \
    -DUSE_SYSTEM_GLUT:BOOL=OFF 
    
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
