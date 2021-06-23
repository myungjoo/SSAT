Name:		ssat
Summary:	Shell Script Automated Tester
Version:	1.2.0
Release:	1
Group:		Development/Tools
Packager:	MyungJoo Ham <myungjoo.ham@samsung.com>
License:	Apache-2.0
Source0:	ssat-%{version}.tar.gz
Source1001:	ssat.manifest
BuildArch:	noarch

Requires:	bash
Requires:	perl

%description
SSAT provides testing environment for shell scripts with Apache-2.0 license.
This is created to avoid any complications related with GPL licenses.

%prep
%setup -q
cp %{SOURCE1001} .

%build
# DO NOTHING

%install
mkdir -p %{buildroot}%{_bindir}
install -p -m 0755 ssat.sh %{buildroot}%{_bindir}/
install -p -m 0644 ssat-api.sh %{buildroot}%{_bindir}/
pushd %{buildroot}%{_bindir}
ln -s ssat.sh ssat
popd

%files
%manifest ssat.manifest
%{_bindir}/ssat
%{_bindir}/ssat.sh
%{_bindir}/ssat-api.sh
