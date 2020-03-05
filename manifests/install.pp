# @summary Manages installation of autofs
# @api private
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
}
