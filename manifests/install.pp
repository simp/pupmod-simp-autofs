# **NOTE: THIS IS A [PRIVATE](https://github.com/puppetlabs/puppetlabs-stdlib#assert_private) CLASS**
#
# This class provides for the installation of autofs
#
class autofs::install {
  assert_private()

  package { 'samba-client':
    ensure => $::autofs::samba_package_ensure,
    before => Package['autofs']
  }

  package { 'autofs':
    ensure => $::autofs::autofs_package_ensure
  }

  file { '/etc/autofs':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0640',
    purge  => true
  }
}
