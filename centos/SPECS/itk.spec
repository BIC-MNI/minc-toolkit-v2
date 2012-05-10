Summary: Insight Toolkit
Name: InsightToolkit
Version: 3.20.1
Release: 1
License: GPL
Source: %{name}-%{version}.tar.gz
BuildRoot: /var/tmp/%{name}-root
URL: http://downloads.sourceforge.net/project/itk/itk/3.20/InsightToolkit-3.20.1.tar.gz

%description

%prep
%setup -q

%build
mkdir build
pushd build
%cmake .. \
-DCMAKE_BUILD_TYPE=Release \
-DBUILD_SHARED_LIBS=TRUE \
-DITK_USE_REVIEW=ON \
-DITK_USE_REVIEW_STATISTICS=ON \
-DITK_USE_OPTIMIZED_REGISTRATION_METHODS=ON \
-DITK_USE_CENTERED_PIXEL_COORDINATES_CONSISTENTLY=ON \
-DITK_USE_TRANSFORM_IO_FACTORIES=ON \
-DITK_LEGACY_REMOVE:BOOL=ON \
-DKWSYS_USE_MD5:BOOL=ON \
-DBUILD_EXAMPLES:BOOL=OFF \
-DBUILD_TESTING:BOOL=OFF \
-DITK_INSTALL_LIB_DIR=%{_lib}
make %{?_smp_mflags}
popd

%install
pushd build
make install DESTDIR=%{buildroot}
popd
pushd %{buildroot}
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



%changelog
* Wed Mar 28 2012 Haz-Edine Assemlal <hassemlal@neurorx.com> 1.0
  - Compile ITK 3.20 
