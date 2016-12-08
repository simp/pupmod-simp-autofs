# == Class: autofs
#
# This class provides for the configuration of autofs.
#
# == Parameters
#
# [*master_map_name*]
#   Type: String
#   The default map name for the master map.
#
# [*mount_timeout*]
#   Type: Integer
#   See: auto.master(5) -> GENERAL SYSTEM DEFAULTS CONFIGURATION -> TIMEOUT
#
# [*negative_timeout*]
#   Type: Integer
#   See: auto.master(5) -> GENERAL SYSTEM DEFAULTS CONFIGURATION -> NEGATIVE_TIMEOUT
#
# [*mount_wait*]
#   Type: Integer
#   See: auto.master(5) -> GENERAL SYSTEM DEFAULTS CONFIGURATION -> MOUNT_WAIT
#
# [*umount_wait*]
#   Type: Integer
#   See: auto.master(5) -> GENERAL SYSTEM DEFAULTS CONFIGURATION -> MOUNT_WAIT
#
# [*browse_mode*]
#   Type: [yes|no]
#   See: auto.master(5) -> GENERAL SYSTEM DEFAULTS CONFIGURATION -> BROWSE_MODE
#
# [*append_options*]
#   Type: [yes|no]
#   See: auto.master(5) -> GENERAL SYSTEM DEFAULTS CONFIGURATION -> APPEND_OPTIONS
#
# [*logging*]
#   Type: [none|verbose|debug]
#   See: auto.master(5) -> GENERAL SYSTEM DEFAULTS CONFIGURATION -> LOGGING
#
# [*ldap_uri*]
#   Type: URI String
#   See: auto.master(5) -> LDAP MAPS -> LDAP_TIMEOUT
#
# [*ldap_timeout*]
#   Type: Integer
#   See: auto.master(5) -> LDAP MAPS -> LDAP_TIMEOUT
#
# [*ldap_network_timeout*]
#   Type: Integer
#   See: auto.master(5) -> LDAP MAPS -> LDAP_NETWORK_TIMEOUT
#
# [*search_base*]
#   Type: String
#   See: auto.master(5) -> LDAP MAPS -> SEARCH_BASE
#
# [*map_object_class*]
#   Type: String
#   See: auto.master(5) -> LDAP MAPS -> MAP_OBJECT_CLASS
#
# [*entry_object_class*]
#   Type: String
#   See: auto.master(5) -> LDAP MAPS -> ENTRY_OBJECT_CLASS
#
# [*map_attribute*]
#   Type: String
#   See: auto.master(5) -> LDAP MAPS -> MAP_ATTRIBUTE
#
# [*entry_attribute*]
#   Type: String
#   See: auto.master(5) -> LDAP MAPS -> ENTRY_ATTRIBUTE
#
# [*value_attribute*]
#   Type: String
#   See: auto.master(5) -> LDAP MAPS -> VALUE_ATTRIBUTE
#
# [*map_hash_table_size*]
#   Type: Ratio
#   Set the map cache hash table size.  Should be a power of 2 with a
#   ratio roughly between 1:10 and 1:20 for each map.
#
# [*use_misc_device*]
#   Type: [yes|no]
#   If the kernel supports using the autofs miscellanous device and
#   you wish to use it you must set this configuration option to "yes"
#   otherwise it will not be used.
#
# [*options*]
#   Type: String
#   Options to append to the automount application at start time. See
#   automount(8) for details.
#
# [*ldap_auth_conf_file*]
#   Type: Absolute Path
#   Set the default location for the LDAP authentication configuration
#   file.
#   If set to boolean 'false', this LDAP auth will not be used.
#
# [*enable_nfs*]
#   Type: Boolean
#   Bring NFS along for the ride. This does NOT set up an NFS server
#   but will include the client portions that allow autofs to properly
#   use an NFS connection.
#
# [*stunnel*]
#   Type: Boolean
#   If stunnel is in use, run:
#     pkill -HUP -x automount
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class autofs (
  $master_map_name = 'auto.master',
  $mount_timeout = '600',
  $negative_timeout = '60',
  $mount_wait = '',
  $umount_wait = '',
  $browse_mode = 'no',
  $append_options = 'yes',
  $logging = 'none',
  $ldap_uri = '',
  $ldap_timeout = '',
  $ldap_network_timeout = '',
  $search_base = '',
  $map_object_class = '',
  $entry_object_class = '',
  $map_attribute = '',
  $entry_attribute = '',
  $value_attribute = '',
  $ldap_auth_conf_file = '/etc/autofs_ldap_auth.conf',
  $map_hash_table_size = '',
  $use_misc_device = 'yes',
  $options = '',
  $enable_nfs = true,
  $stunnel = simplib::lookup('simp_options::stunnel', { 'default_value' => false, 'value_type' => Boolean } )
) {

  if $ldap_auth_conf_file {
    include '::autofs::ldap_auth'

    validate_absolute_path($ldap_auth_conf_file)
  }

  validate_integer($mount_timeout)
  validate_integer($negative_timeout)
  if !empty($mount_wait) {
    validate_integer($mount_wait)
  }
  if !empty($umount_wait) {
    validate_integer($umount_wait)
  }
  validate_array_member($browse_mode,['yes','no'])
  validate_array_member($append_options,['yes','no'])
  validate_array_member($logging,['none','verbose','debug'])
  if !empty($ldap_timeout) {
    validate_integer($ldap_timeout)
  }
  if !empty($ldap_network_timeout) {
    validate_integer($ldap_network_timeout)
  }
  validate_array_member($use_misc_device,['yes','no'])
  validate_bool($enable_nfs)
  validate_bool($stunnel)


  file { '/etc/autofs':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0640'
  }

  file { '/etc/sysconfig/autofs':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('autofs/etc/sysconfig/autofs.erb'),
    notify  => Service['autofs']
  }

  package { 'autofs':
    ensure  => 'latest'
  }

  package { 'samba-client':
    ensure => 'latest',
    before => Package['autofs']
  }

  service { 'autofs':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['autofs']
  }

  if $enable_nfs {
    include '::nfs'

    Package['nfs-utils'] -> Package['autofs']
    Service['autofs'] ~> Service[$::nfs::service_names::rpcbind]

    if $stunnel {
      include '::stunnel'

      # Ugly exec to break the dependency cycle Service[autofs] =>
      # Service[rpcbind] => Service[nfs] => Service[stunnel] => Service[autofs]
      exec { 'refresh_autofs':
        command     => 'pkill -HUP -x automount',
        refreshonly => true
      }
      Service['stunnel'] ~> Exec['refresh_autofs']
    }
  }

}
