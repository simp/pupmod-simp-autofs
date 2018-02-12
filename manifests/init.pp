# This class provides for the configuration of ``autofs``
#
# @see auto.master(5)
# @see automount(8)
#
# @param master_map_name
#   The default map name for the master map
#
# @param mount_timeout
#   See: auto.master(5) -> GENERAL SYSTEM DEFAULTS CONFIGURATION -> TIMEOUT
#
# @param negative_timeout
#   See: auto.master(5) -> GENERAL SYSTEM DEFAULTS CONFIGURATION -> NEGATIVE_TIMEOUT
#
# @param mount_wait
#   Type: Integer
#   See: auto.master(5) -> GENERAL SYSTEM DEFAULTS CONFIGURATION -> MOUNT_WAIT
#
# @param umount_wait
#   See: auto.master(5) -> GENERAL SYSTEM DEFAULTS CONFIGURATION -> MOUNT_WAIT
#
# @param browse_mode
#   See: auto.master(5) -> GENERAL SYSTEM DEFAULTS CONFIGURATION -> BROWSE_MODE
#
# @param append_options
#   Type: [yes|no]
#   See: auto.master(5) -> GENERAL SYSTEM DEFAULTS CONFIGURATION -> APPEND_OPTIONS
#
# @param logging
#   Type: [none|verbose|debug]
#   See: auto.master(5) -> GENERAL SYSTEM DEFAULTS CONFIGURATION -> LOGGING
#
# @param ldap_uri
#   See: auto.master(5) -> LDAP MAPS -> LDAP_TIMEOUT
#
# @param ldap_timeout
#   See: auto.master(5) -> LDAP MAPS -> LDAP_TIMEOUT
#
# @param ldap_network_timeout
#   See: auto.master(5) -> LDAP MAPS -> LDAP_NETWORK_TIMEOUT
#
# @param search_base
#   See: auto.master(5) -> LDAP MAPS -> SEARCH_BASE
#
# @param map_object_class
#   See: auto.master(5) -> LDAP MAPS -> MAP_OBJECT_CLASS
#
# @param entry_object_class
#   See: auto.master(5) -> LDAP MAPS -> ENTRY_OBJECT_CLASS
#
# @param map_attribute
#   See: auto.master(5) -> LDAP MAPS -> MAP_ATTRIBUTE
#
# @param entry_attribute
#   See: auto.master(5) -> LDAP MAPS -> ENTRY_ATTRIBUTE
#
# @param value_attribute
#   See: auto.master(5) -> LDAP MAPS -> VALUE_ATTRIBUTE
#
# @param map_hash_table_size
#   Set the map cache hash table size
#
#   * Should be a power of 2 with a ratio roughly between 1:10 and 1:20 for
#     each map
#
# @param use_misc_device
#   If the kernel supports using the autofs miscellanous device, and you wish
#   to use it, you must set this configuration option to ``yes`` otherwise it
#   will not be used
#
# @param options
#   Options to append to the automount application at start time
#
#   * See ``automount(8)`` for details
#
# @param samba_package_ensure
#   The value to pass to the `ensure` parameter of the `samba-utils` package.
#   Defaults to `simp_options::package_ensure` or `installed`
#
# @param autofs_package_ensure
#   The value to pass to the `ensure` parameter of the `autofs` package.
#   Defaults to `simp_options::package_ensure` or `installed`
#
# @param ldap
#   Enable LDAP lookups
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
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
#
class autofs (
  String                         $master_map_name       = 'auto.master',
  Integer                        $mount_timeout         = 600,
  Integer                        $negative_timeout      = 60,
  Optional[Integer]              $mount_wait            = undef,
  Optional[Integer]              $umount_wait           = undef,
  Boolean                        $browse_mode           = false,
  Boolean                        $append_options        = true,
  Enum['none','verbose','debug'] $logging               = 'none',
  Optional[Simplib::Uri]         $ldap_uri              = undef,
  Optional[Integer]              $ldap_timeout          = undef,
  Optional[Integer]              $ldap_network_timeout  = undef,
  Optional[String]               $search_base           = undef,
  Optional[String]               $map_object_class      = undef,
  Optional[String]               $entry_object_class    = undef,
  Optional[String]               $map_attribute         = undef,
  Optional[String]               $entry_attribute       = undef,
  Optional[String]               $value_attribute       = undef,
  Optional[Integer]              $map_hash_table_size   = undef,
  Boolean                        $use_misc_device       = true,
  Optional[String]               $options               = undef,
  String                         $samba_package_ensure  = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' }),
  String                         $autofs_package_ensure = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' }),
  Boolean                        $ldap                  = simplib::lookup('simp_options::ldap', { 'default_value' => false }),
  Variant[Enum['simp'],Boolean]  $pki                   = simplib::lookup('simp_options::pki', { 'default_value' => false })
) {

  contain '::autofs::install'
  contain '::autofs::service'

  file { '/etc/sysconfig/autofs':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('autofs/etc/sysconfig/autofs.erb'),
    require => Class['autofs::install'],
    notify  => Class['autofs::service']
  }

  Class['autofs::install'] ~> Class['autofs::service']

  if $ldap {
    include '::autofs::ldap_auth'

    Class['autofs::ldap_auth'] ~> Class['autofs::service']
  }
}
