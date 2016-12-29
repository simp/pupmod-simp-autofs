# == Class autofs::ldap_auth
#
# Set up the autofs_ldap_auth.conf file
#
# == Parameters
#
# [*ldap_auth_conf_file*]
#   Type: Absolute Path
#   Set the default location for the LDAP authentication configuration
#   file.
#
# [*usetls*]
#   Type: [yes|no]
#   Determines whether an encrypted connection to the ldap server
#   should be attempted.
#
# [*tlsrequired*]
#   Type: [yes|no]
#   This flag tells whether the ldap connection must be encrypted.  If
#   set to "yes", the automounter will fail to start if an encrypted
#   connection cannot be established.
#
# [*authrequired*]
#   Type: [yes|no|autodetect|simple]
#   This option tells whether an authenticated connection to the ldap
#   server is required in order to perform ldap queries.  If this flag
#   is set to yes, then only authenticated connections will be
#   allowed. If it is set to no then authentication is not needed for
#   ldap server connections.  Finally, if it is set to autodetect then
#   the ldap server will be queried to establish a suitable
#   authentication mechanism. If no suitable mechanism can be found,
#   connections to the ldap server are made without authentication.
#
# [*authtype*]
#   Type: [GSSAPI|LOGIN|PLAIN|ANONYMOUS|DIGEST-MD5|EXTERNAL]
#   This attribute can be used to specify a preferred authentication
#   mechanism.  In normal operations, the automounter will attempt to
#   authenticate to the ldap server using the list of
#   supportedSASLmechanisms obtained from the directory server.
#   Explicitly setting the authtype will bypass this selection and
#   only try the mechanism specified. The EXTERNAL mechanism may be
#   used to authenticate using a client certificate and requires that
#   authrequired set to "yes" if using SSL or usetls, tlsrequired and
#   authrequired all set to "yes" if using TLS, in addition to
#   authtype being set EXTERNAL.
#
# [*external_cert*]
#   Type: Absolute Path
#   This specifies the path of the file containing the client
#   certificate.
#
# [*external_key*]
#   Type: Absolute Path
#   This specifies the path of the file containing the client
#   certificate key.
#
# [*user*]
#   Type: String
#   This attribute holds the authentication identity used by
#   authentication mechanisms that require it.  Legal values for this
#   attribute include any printable characters that can be used by the
#   selected authentication mechanism.
#
# [*secret*]
#   Type: String
#   This attribute holds the secret used by authentication mechanisms
#   that require it.  Legal values for this attribute include any
#   printable characters that can be used by the selected
#   authentication mechanism.
#
# [*clientprinc*]
#   Type: KRB5 Principal
#   When using GSSAPI authentication, this attribute is consulted to
#   determine the principal name to use when authenticating to the
#   directory server.  By default, this will be set to
#   "autofsclient/<fqdn>@<REALM>.
#
# [*credentialcache*]
#   Type: Absolute Path
#   When using GSSAPI authentication, this attribute can be used to
#   specify an externally configured credential cache that is used
#   during authentication. By default, autofs will setup a memory
#   based credential cache.
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class autofs::ldap_auth (
  String                                  $user                = simplib::lookup('simp_options::ldap::bind_dn', { 'default_value'   => "cn = hostAuth,ou = Hosts,%{hiera('simp_options::ldap::base_dn')}" }),
  String                                  $secret              = simplib::lookup('simp_options::ldap::bind_pw'),
  Stdlib::Absolutepath                    $ldap_auth_conf_file = hiera('autofs::ldap_auth_conf_file','/etc/autofs_ldap_auth.conf'),
  Enum['yes','no']                        $usetls              = 'yes',
  Enum['yes','no']                        $tlsrequired         = 'yes',
  Enum['yes','no','autodetect','simple']  $authrequired        = 'yes',
  Autofs::Authtype                        $authtype            = 'LOGIN',
  Variant[Stdlib::Absolutepath,Boolean]   $external_cert       = "/etc/pki/simp/public/${::fqdn}.pub",
  Variant[Stdlib::Absolutepath,Boolean]   $external_key        = "/etc/pki/simp/private/${::fqdn}.pem",
  Optional[String]                        $clientprinc         = undef,
  Optional[Stdlib::Absolutepath]          $credentialcache     = undef
  ) {

  if upcase($authtype) == 'EXTERNAL' {
    if (!$external_cert or !$external_key) {
      fail '$external_cert and $external_key must be specified when setting $authtype to "EXTERNAL"'
    }
  }

  file { $ldap_auth_conf_file:
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('autofs/ldap_auth.erb'),
    notify  => Service['autofs']
  }
}
