# **NOTE: THIS IS A [PRIVATE](https://github.com/puppetlabs/puppetlabs-stdlib#assert_private) CLASS**
#
# This class provides for the installation of autofs
#
class autofs::service {
  service { 'autofs':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true
  }
}
