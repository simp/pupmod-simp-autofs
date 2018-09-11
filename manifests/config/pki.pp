# This class controls all pki related articles for autofs
#
# @param pki
#   * If 'simp', include SIMP's pki module and use pki::copy to manage
#     application certs in /etc/pki/simp_apps/autofs/x509
#   * If true, do *not* include SIMP's pki module, but still use pki::copy
#     to manage certs in /etc/pki/simp_apps/autofs/x509
#   * If false, do not include SIMP's pki module and do not use pki::copy
#     to manage certs.  You will need to appropriately assign a subset of:
#     * app_pki_dir
#     * app_pki_key
#     * app_pki_cert
#     * app_pki_ca
#     * app_pki_ca_dir
#
# @param app_pki_external_source
#   * If pki = 'simp' or true, this is the directory from which certs will be
#     copied, via pki::copy.  Defaults to /etc/pki/simp/x509.
#
#   * If pki = false, this variable has no effect.
#
# @param app_pki_dir
#   This variable controls the basepath of $app_pki_key, $app_pki_cert,
#   $app_pki_ca, $app_pki_ca_dir, and $app_pki_crl.
#   It defaults to /etc/pki/simp_apps/autofs/x509.
#
# @param app_pki_key
#   Path and name of the private SSL key file
#
# @param app_pki_cert
#   Path and name of the public SSL certificate
#
class autofs::config::pki(
  String               $app_pki_external_source = simplib::lookup('simp_options::pki::source', { 'default_value' => '/etc/pki/simp/x509' }),
  Stdlib::Absolutepath $app_pki_dir             = '/etc/pki/simp_apps/autofs/x509',
  Stdlib::Absolutepath $app_pki_cert            = "${app_pki_dir}/public/${::fqdn}.pub",
  Stdlib::Absolutepath $app_pki_key             = "${app_pki_dir}/private/${::fqdn}.pem"
) {
  assert_private()

  if $::autofs::pki {
    pki::copy { 'autofs':
      source => $app_pki_external_source,
      pki    => $::autofs::pki
    }
  }
}
