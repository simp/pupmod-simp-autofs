Summary: AutoFS Puppet Module
Name: pupmod-autofs
Version: 4.1.0
Release: 7
License: Apache License, Version 2.0
Group: Applications/System
Source: %{name}-%{version}-%{release}.tar.gz
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Requires: puppetlabs-stdlib >= 3.2.0
Requires: pupmod-simpcat >= 2
Requires: pupmod-nfs >= 4.1.0-8
Requires: puppet >= 3.3.0
Buildarch: noarch
Requires: simp-bootstrap >= 4.2.0
Obsoletes: pupmod-autofs-test

Prefix:"/etc/puppet/environments/simp/modules"

%description
This Puppet module allows for the configuration of AutoFS.

%prep
%setup -q

%build

%install
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/autofs

dirs='files lib manifests templates'
for dir in $dirs; do
  test -d $dir && cp -r $dir %{buildroot}/%{prefix}/autofs
done

mkdir -p %{buildroot}/usr/share/simp/tests/modules/autofs

%clean
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/autofs

%files
%defattr(0640,root,puppet,0750)
/etc/puppet/environments/simp/modules/autofs

%post
#!/bin/sh

if [ -d /etc/puppet/environments/simp/modules/autofs/plugins ]; then
  /bin/mv /etc/puppet/environments/simp/modules/autofs/plugins /etc/puppet/environments/simp/modules/autofs/plugins.bak
fi

%postun
# Post uninstall stuff

%changelog
* Mon Nov 09 2015 Chris Tessmer <chris.tessmer@onypoint.com> - 4.1.0-7
- migration to simplib and simpcat (lib/ only)

* Fri Jan 16 2015 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-6
- Changed puppet-server requirement to puppet

* Fri Sep 19 2014 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-5
- Updated to be compatible with RHEL7

* Sun Jun 22 2014 Kendall Moore <kmoore@keywcorp.com> - 4.1.0-4
- Removed MD5 file checksums for FIPS compliance.

* Tue May 06 2014 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-3
- If nfs is using stunnel, then have a restart of stunnel trigger a
  restart of autofs in an attempt to have consistency when
  transitioning into an stunnel setup.

* Mon Apr 21 2014 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-2
- Updated ldap_bind_dn and ldap_bind_pw to use hiera settings instead.

* Thu Feb 27 2014 Kendall Moore <kmoore@keywcorp.com> - 4.1.0-1
- Added reasonable defaults for user and secret in ldap_auth.pp

* Mon Dec 16 2013 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-0
- Updated the code to work with Puppet 3 and Hiera.
- Integrated the full Puppet spec test suite.

* Thu Oct 03 2013 Kendall Moore <kmoore@keywcorp.com> - 2.0.0-10
- Updated all erb templates to properly scope variables.

* Thu Jan 31 2013 Maintenance
2.0.0-9
- Created a Cucumber test that mounts a test folder in a different location to see if module is working properly.

* Thu Aug 02 2012 Maintenance
2.0.0-8
- Updated the autofs::map::entry to be able to handle entries with '/' in them.

* Wed Apr 11 2012 Maintenance
2.0.0-7
- Moved mit-tests to /usr/share/simp...
- Updated pp files to better meet Puppet's recommended style guide.

* Fri Mar 02 2012 Maintenance
2.0.0-6
- Improved test stubs.

* Mon Jan 30 2012 Maintenance
2.0.0-5
- Added test stubs.

* Mon Dec 26 2011 Maintenance
2.0.0-4
- Updated the spec file to not require a separate file list.

* Thu Oct 27 2011 Maintenance
2.0.0-3
- Now pull the name of the portmap service from an nfs class variable since it
  changes between RHEL5 and RHEL6.

* Thu Jul 07 2011 Maintenance
2.0.0-1
- Fixed wildcard key support. You can now specify one wildcard entry as
  'wildcard' but all define calls must be unique, so you can specify other
  wildcard entries with 'wildcard-<some_unique_name>'

* Fri Apr 22 2011 Maintenance - 1.0-0
- Initial offering of an AutoFS module.
