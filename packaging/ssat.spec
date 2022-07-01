Name:		ssat
Summary:	Shell Script Automated Tester
Version:	1.3.0
Release:	0
Group:		Development/Tools
Packager:	MyungJoo Ham <myungjoo.ham@samsung.com>
License:	Apache-2.0
Source0:	ssat-%{version}.tar.gz
Source1001:	ssat.manifest

Requires:	bash
Requires:	perl

## For the utility
BuildRequires:	meson
BuildRequires:	ninja
BuildRequires:	pkgconfig(libpng)
BuildRequires:	glib2-devel

%description
SSAT provides testing environment for shell scripts with Apache-2.0 license.
This is created to avoid any complications related with GPL licenses.

%prep
%setup -q
cp %{SOURCE1001} .

%build
# Utilities
meson --prefix=%{_prefix} --bindir=bin build util
ninja -C build

%install
mkdir -p %{buildroot}%{_bindir}
install -p -m 0755 ssat.sh %{buildroot}%{_bindir}/
install -p -m 0644 ssat-api.sh %{buildroot}%{_bindir}/
pushd %{buildroot}%{_bindir}
ln -s ssat.sh ssat
popd
DESTDIR=%{buildroot} ninja -C build install

%files
%manifest ssat.manifest
%{_bindir}/ssat
%{_bindir}/ssat.sh
%{_bindir}/ssat-api.sh
%{_bindir}/bmp2png
