# Set up the ``autofs_ldap_auth.conf`` file
#
# @param ldap_auth_conf_file
#   Set the default location for the LDAP authentication configuration file
#
# @param usetls
#   Determines whether an encrypted connection to the ldap server should be
#   attempted
#
# @param tlsrequired
#   Encrypt the LDAP connection
#
#   * If set to ``yes``, the automounter will fail to start if an encrypted
#     connection cannot be established
#
# @param authrequired
#   This option tells whether an authenticated connection to the ldap
#   server is required in order to perform ldap queries
#
#   * If this flag is set to ``yes``, then only authenticated connections will
#     be allowed
#   * If it is set to ``no`` then authentication is not needed for ldap server
#     connections
#   * If it is set to ``autodetect`` then the ldap server will be queried to
#     establish a suitable authentication mechanism
#   * If no suitable mechanism can be found, connections to the ldap server are
#     made without authentication
#
# @param authtype
#   This attribute can be used to specify a preferred authentication mechanism
#
#   * In normal operations, the automounter will attempt to authenticate to the
#   ldap server using the list of ``supportedSASLmechanisms`` obtained from the
#   directory server
#   * Explicitly setting the authtype will bypass this selection and only try
#   the mechanism specified
#   * The ``EXTERNAL`` mechanism may be used to authenticate using a client
#     certificate and requires that authrequired set to ``yes`` if using SSL or
#     ``usetls``, ``tlsrequired`` and ``authrequired`` all set to ``yes`` if
#     using TLS, in addition to ``authtype`` being set ``EXTERNAL``
#
# @param external_cert
#   This specifies the path of the file containing the client certificate.
#   Set ::autofs::pki to false if you don't want SIMP to manage this cert.
#
# @param external_key
#   This specifies the path of the file containing the client certificate key
#   Set ::autofs::pki to false if you don't want SIMP to manage this key.
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
#   When using ``GSSAPI`` authentication, this attribute is consulted to
#   determine the principal name to use when authenticating to the directory
#   server
#
# @param credentialcache
#   When using ``GSSAPI`` authentication, this attribute can be used to specify
#   an externally configured credential cache that is used during
#   authentication
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
#
class autofs::ldap_auth (
  Optional[String]                              $user                = simplib::lookup('simp_options::ldap::bind_dn', { 'default_value' => undef }),
  Optional[String]                              $secret              = simplib::lookup('simp_options::ldap::bind_pw', { 'default_value' =>  undef}),
  Stdlib::Absolutepath                          $ldap_auth_conf_file = '/etc/autofs_ldap_auth.conf',
  Boolean                                       $usetls              = true,
  Boolean                                       $tlsrequired         = true,
  Variant[Boolean, Enum['autodetect','simple']] $authrequired        = true,
  Autofs::Authtype                              $authtype            = 'LOGIN',
  Stdlib::Absolutepath                          $external_cert       = "/etc/pki/simp_apps/autofs/x509/public/${facts['fqdn']}.pub",
  Stdlib::Absolutepath                          $external_key        = "/etc/pki/simp_apps/autofs/x509/private/${facts['fqdn']}.pem",
  Optional[String]                              $clientprinc         = undef,
  Optional[Stdlib::Absolutepath]                $credentialcache     = undef
) {

  file { $ldap_auth_conf_file:
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template("${module_name}/etc/ldap_auth.erb")
  }

  if $authtype == 'EXTERNAL' {
    include '::autofs::config::pki'
    Class['::autofs::config::pki'] ~> Class['::autofs::service']
  }
}
