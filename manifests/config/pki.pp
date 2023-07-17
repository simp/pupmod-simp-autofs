# @summary Controls all pki related articles for autofs
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
# @api private
#
# @author https://github.com/simp/pupmod-simp-autofs/graphs/contributors
#
class autofs::config::pki(
  String               $app_pki_external_source = simplib::lookup('simp_options::pki::source', { 'default_value' => '/etc/pki/simp/x509' }),
  Stdlib::Absolutepath $app_pki_dir             = '/etc/pki/simp_apps/autofs/x509',
  Stdlib::Absolutepath $app_pki_cert            = "${app_pki_dir}/public/${facts['networking']['fqdn']}.pub",
  Stdlib::Absolutepath $app_pki_key             = "${app_pki_dir}/private/${facts['networking']['fqdn']}.pem"
) {
  assert_private()

  if $autofs::pki {
    pki::copy { 'autofs':
      source => $app_pki_external_source,
      pki    => $autofs::pki
    }
  }
}
