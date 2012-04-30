Summary: MNI Display
Name: Display
Version: 1.6.4
Release: 1
License: GPL
Source: %{name}-%{version}.tar.bz2
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
URL: git@github.com:hassemlal/Display.git

%description
MNI-Display is an interactive program to display and segment 3 
dimensional images, as well as to display and manipulate 3D 
geometric objects.

%prep
%setup -q

%build
mkdir build
pushd build
%cmake .. \
-DCMAKE_BUILD_TYPE=Release \
-DBUILD_SHARED_LIBS=TRUE
make %{?_smp_mflags}
popd


%install
rm -rf $RPM_BUILD_ROOT
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
rm -rf $RPM_BUILD_ROOT

%files -f ../file.list.%{name} 

%changelog
* Fri Apr 13 2012 root <root@proc-test2.neurorx.com> 1.6.4 
- Initial build 1.6.4

