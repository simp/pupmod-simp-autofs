# **NOTE: THIS IS A [PRIVATE](https://github.com/puppetlabs/puppetlabs-stdlib#assert_private) CLASS**
#
# This class provides for the installation of autofs
#
class autofs::config::pki {
  assert_private()

  include '::pki'
  pki::copy { $::autofs::app_pki_dir: }
}
