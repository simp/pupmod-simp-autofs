# **NOTE: THIS IS A [PRIVATE](https://github.com/puppetlabs/puppetlabs-stdlib#assert_private) CLASS**
#
# This class provides for the installation of autofs
#
class autofs::install {
  assert_private()

  package { 'samba-client':
    ensure => 'latest',
    before => Package['autofs']
  }

  package { 'autofs': ensure  => 'latest' }

  file { '/etc/autofs':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0640'
  }
}
