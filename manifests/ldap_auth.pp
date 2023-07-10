# @summary Set up the `autofs_ldap_auth.conf` file
#
# @param ldap_auth_conf_file
#   Set the location of the LDAP authentication configuration file
#
# @param usetls
#   Determines whether an encrypted connection to the ldap server should be
#   attempted
#
# @param tlsrequired
#   Encrypt the LDAP connection
#
#   * If enabled, the automounter will fail to start if an encrypted
#     connection cannot be established
#
# @param authrequired
#   This option tells whether an authenticated connection to the ldap
#   server is required in order to perform ldap queries
#
#   * If this flag is set to `true`, then only authenticated connections will
#     be allowed
#   * If it is set to `false` then authentication is not needed for ldap server
#     connections
#   * If it is set to `autodetect` then the ldap server will be queried to
#     establish a suitable authentication mechanism
#   * If no suitable mechanism can be found, connections to the ldap server are
#     made without authentication
#
# @param authtype
#   This attribute can be used to specify a preferred authentication mechanism
#
#   * In normal operations, the automounter will attempt to authenticate to the
#     ldap server using the list of `supportedSASLmechanisms` obtained from the
#     directory server
#   * Explicitly setting `$authtype` will bypass this selection and only try
#     the mechanism specified
#   * The `EXTERNAL` mechanism may be used to authenticate using a client
#     certificate and requires that `$authrequired` is set to `true` if using SSL
#     or `$usetls`, `$tlsrequired` and `$authrequired` are all set to `true` if
#     using TLS, in addition to `authtype` being set `EXTERNAL`
#
# @param external_cert
#   This specifies the path of the file containing the client certificate.
#   Set `$autofs::pki` to `false` if you don't want SIMP to manage this cert.
#
# @param external_key
#   This specifies the path of the file containing the client certificate key
#   Set `$autofs::pki` to `false` if you don't want SIMP to manage this key.
#
# @param user
#   This attribute holds the authentication identity used by authentication
#   mechanisms that require it
#
#   * Legal values for this attribute include any printable characters that can
#     be used by the selected authentication mechanism
#
# @param secret
#   This attribute holds the secret used by authentication mechanisms that
#   require it
#
#   * Legal values for this attribute include any printable characters that can
#     be used by the selected authentication mechanism
#
# @param clientprinc
#   When using `GSSAPI` authentication, this attribute is consulted to
#   determine the principal name to use when authenticating to the directory
#   server
#
# @param credentialcache
#   When using `GSSAPI` authentication, this attribute can be used to specify
#   an externally configured credential cache that is used during
#   authentication
#
# @api private
#
# @author https://github.com/simp/pupmod-simp-autofs/graphs/contributors
#
class autofs::ldap_auth (
  Optional[String]                              $user                = simplib::lookup('simp_options::ldap::bind_dn', { 'default_value' => undef }),
  Optional[String]                              $secret              = simplib::lookup('simp_options::ldap::bind_pw', { 'default_value' =>  undef}),
  Optional[String]                              $encoded_secret      = undef,
  Stdlib::Absolutepath                          $ldap_auth_conf_file = $autofs::auth_conf_file,
  Boolean                                       $usetls              = true,
  Boolean                                       $tlsrequired         = true,
  Variant[Boolean, Enum['autodetect','simple']] $authrequired        = true,
  Autofs::Authtype                              $authtype            = 'LOGIN',
  Stdlib::Absolutepath                          $external_cert       = "/etc/pki/simp_apps/autofs/x509/public/${facts['networking']['fqdn']}.pub",
  Stdlib::Absolutepath                          $external_key        = "/etc/pki/simp_apps/autofs/x509/private/${facts['networking']['fqdn']}.pem",
  Optional[String]                              $clientprinc         = undef,
  Optional[Stdlib::Absolutepath]                $credentialcache     = undef
) {
  assert_private()

  file { $ldap_auth_conf_file:
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => epp("${module_name}/etc/autofs_ldap_auth.conf.epp")
  }

  if $authtype == 'EXTERNAL' {
    contain 'autofs::config::pki'
  }
}
