Name:           perl-App-Cope
Version:        1.00
Release:        1%{?dist}
Summary:        App::Cope Perl module
License:        Non-distributable, see LICENSE
Group:          Development/Libraries
URL:            http://search.cpan.org/dist/App-Cope/
Source0:        http://www.cpan.org/modules/by-module/App/App-Cope-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
BuildRequires:  perl(Env::Path)
BuildRequires:  perl(ExtUtils::MakeMaker)
BuildRequires:  perl(File::ShareDir)
BuildRequires:  perl(IO::Pty)
BuildRequires:  perl(IO::Stty)
BuildRequires:  perl(List::MoreUtils)
BuildRequires:  perl(Regexp::Common)
BuildRequires:  perl(Regexp::IPv6)
Requires:       perl(Env::Path)
Requires:       perl(File::ShareDir)
Requires:       perl(IO::Pty)
Requires:       perl(IO::Stty)
Requires:       perl(List::MoreUtils)
Requires:       perl(Regexp::Common)
Requires:       perl(Regexp::IPv6)
Requires:       perl(Number::Format)
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))

%description
cope is a wrapper around programs that output to a terminal, to give them
colour for utility and aesthetics while still keeping them the same at the
text level.

%prep
%setup -q -n App-Cope-%{version}

%build
%{__perl} Makefile.PL INSTALLDIRS=vendor
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT

make pure_install PERL_INSTALL_ROOT=$RPM_BUILD_ROOT

find $RPM_BUILD_ROOT -type f -name .packlist -exec rm -f {} \;
find $RPM_BUILD_ROOT -depth -type d -exec rmdir {} 2>/dev/null \;

%{_fixperms} $RPM_BUILD_ROOT/*

%check
make test

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%doc LICENSE README
%{perl_vendorlib}/*
%{_mandir}/man3/*
%{_usr}/bin/*

%changelog
* Mon Jun 19 2017 Rick Hansen <nichivo@goemail.xyz> 1.00-1
- Milestone release

* Fri Mar 10 2017 Rick Hansen <nichivo@goemail.xyz> 0.99-1
- Initial release
