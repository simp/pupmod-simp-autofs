# @summary Manage the installation and configuration of `autofs` and ensure
# its service is running.
#
# @see autofs.conf(5)
#
# @param timeout
#   Default mount timeout in seconds
#
#   * 'timeout' parameter in the 'autofs' section of /etc/autofs.conf
#
# @param master_wait
#   Default maximum time to wait in seconds for the master map to become
#   available if it cannot be read at program start
#
#   * 'master_wait' parameter in the 'autofs' section of /etc/autofs.conf
#
# @param negative_timeout
#   Default timeout for caching failed key lookups
#
#   * 'negative_timeout' parameter in the 'autofs' section of /etc/autofs.conf
#
# @param mount_verbose
#   Use the verbose flag when spawning mount
#
#   * 'mount_verbose' parameter in the 'autofs' section of /etc/autofs.conf
#
# @param mount_wait
#   Default time to wait for a response from a spawned mount before sending
#   it a SIGTERM
#
#   * 'mount_wait' parameter in the 'autofs' section of /etc/autofs.conf
#
# @param umount_wait
#   Default time to wait for a response from a spawned umount before sending
#   it a SIGTERM
#
#   * 'umount_wait' parameter in the 'autofs' section of /etc/autofs.conf
#
# @param browse_mode
#   Whether maps are browsable
#
#   * 'browse_mode' parameter in the 'autofs' section of /etc/autofs.conf
#
# @param mount_nfs_default_protocol
#   Default protocol that mount.nfs uses when performing a mount
#
#   * 'mount_nfs_default_protocol' parameter in the 'autofs' section of
#     /etc/autofs.conf
#
# @param append_options
#   Whether global options are appended to map entry options
#
#   * 'append_options' parameter in the 'autofs' section of /etc/autofs.conf
#
# @param logging
#   Default log level
#
#   * 'logging' parameter in the 'autofs' section of /etc/autofs.conf
#
# @param force_standard_program_map_env
#   Override the use of a prefix with standard environment variables when a
#   program map is executed
#
#   * 'force_standard_program_map_env' parameter in the 'autofs' section of
#     /etc/autofs.conf
#
# @param map_hash_table_size
#   Set the number of hash table slots
#
#   * Should be a power of 2 with a ratio roughly between 1:10 and 1:20 for
#     each map
#   * 'map_hash_table_size' parameter in the 'autofs' section of
#     /etc/autofs.conf
#
# @param use_hostname_for_mounts
#   NFS mounts where the host name resolves to more than one IP address are
#   probed for availability and to establish the order in which mounts to them
#   should be tried
#
#   * 'use_hostname_for_mounts' parameter in the 'autofs' section of
#     /etc/autofs.conf
#
# @param disable_not_found_message
#   Turn off not found messages
#
#   * 'disable_not_found_message' parameter in the 'autofs' section of
#     /etc/autofs.conf
#
# @param sss_master_map_wait
#   Time to wait and retry if sssd returns "no such entry" when starting up
#
#   * 'sss_master_map_wait' parameter in the 'autofs' section of
#     /etc/autofs.conf
#
# @param use_mount_request_log_id
#   Whether to use a mount request log id so that log entries for specific
#   mount requests can be easily identified in logs that have multiple
#   concurrent requests
#
#   * 'use_mount_request_log_id' parameter in the 'autofs' section of
#     /etc/autofs.conf
#
# @param ldap_uri
#   An LDAP server URI
#
#   * Only applies if `$ldap` is `true`.
#   * 'ldap_uri' parameter in the 'autofs' section of /etc/autofs.conf, which
#     can be specified multiple times
#
# @param ldap_timeout
#   Network response timeout value for the synchronous API calls
#
#   * Only applies if `$ldap` is `true`.
#   * 'ldap_timeout' parameter in the 'autofs' section of /etc/autofs.conf
#
# @param ldap_network_timeout
#   Network response timeout
#
#   * Only applies if `$ldap` is `true`.
#   * 'ldap_network_timeout' parameter in the 'autofs' section of
#     /etc/autofs.conf
#
#
# @param search_base
#   Base `dn` to use when searching for a map base `dn`
#
#   * Only applies if `$ldap` is `true`.
#   * 'search_base' parameter in the 'autofs' section of /etc/autofs.conf,
#     which can be specified multiple times
#
# @param map_object_class
#   Map object class
#
#   * Only applies if `$ldap` is `true`.
#   * 'map_object_class' parameter in the 'autofs' section of /etc/autofs.conf
#
#
# @param entry_object_class
#   Map entry object class
#
#   * Only applies if `$ldap` is `true`.
#   * 'entry_object_class' parameter in the 'autofs' section of /etc/autofs.conf
#
# @param map_attribute
#   Attribute used to identify the name of the map to which this entry belongs
#
#   * Only applies if `$ldap` is `true`.
#   * 'map_attribute' parameter in the 'autofs' section of /etc/autofs.conf
#
# @param entry_attribute
#   Attribute used to identify a map key
#
#   * Only applies if `$ldap` is `true`.
#   * 'entry_attribute' parameter in the 'autofs' section of /etc/autofs.conf
#
# @param value_attribute
#   Attribute used to identify the value of the map entry
#
#   * Only applies if `$ldap` is `true`.
#   * 'value_attribute' parameter in the 'autofs' section of /etc/autofs.conf
#
# @param auth_conf_file
#   Location of the ldap authentication configuration file
#
#   * Only applies if `$ldap` is `true`.
#   * 'auth_conf_file' parameter in the 'autofs' section of /etc/autofs.conf
#
# @param custom_autofs_conf_options
#   Custom key/value pairs to be set in the 'autofs' section of /etc/autofs.conf
#
#   * Useful to add new configuration parameters before they are managed by
#     this module
#   * No validation will be done to this configuration.
#
# @param automount_use_misc_device
#   Whether to use autofs miscellanous device when the kernel supports it
#
#   * 'USE_MISC_DEVICE' environment variable in /etc/sysconfig/autofs
#
# @param automount_options
#   Options to append to the automount application at start time
#
#   * See automount(8) for details
#   * 'OPTIONS' environment variable in /etc/sysconfig/autofs
#
# @param master_conf_dir
#   Directory for SIMP-managed auto.master configuration files
#
# @param master_include_dirs
#   Other directories of auto.master configuration files to include
#
#   * This module will not manage these directories or their contents.
#
# @param maps_dir
#   Directory for SIMP-managed map files
#
# @param maps
#   Specification of 'file' maps to be configured
#
#   * An autofs master entry file and map file will be created for each map
#     specification.
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
#   * Further configuration may need to be made in the `autofs::ldap_auth` class
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
# @example Specify 'file' type maps in hieradata
#   ---
#   autofs::maps:
#     # direct mount
#     data:
#       mount_point: "/-"
#       mappings:
#         # mappings is a single Hash for direct maps
#         key:      "/net/data"
#         options:  "-fstype=nfs,soft,nfsvers=4,ro"
#         location: "nfs.example.com:/exports/data"
#
#     # indirect mount with wildcard key and key substitution
#     home:
#       mount_point:    "/home"
#       master_options: "strictexpire --strict"
#       mappings:
#         # mappings is an Array for indirect maps
#         - key:      "*"
#           options:  "-fstype=nfs,soft,nfsvers=4,rw"
#           location: "nfs.example.com:/exports/home/&"
#
#     # indirect mount with multiple, explicit keys
#     apps:
#       mount_point: "/net/apps"
#       mappings:
#         - key:      "v1"
#           options:  "-fstype=nfs,soft,nfsvers=4,ro"
#           location: "nfs.example.com:/exports/apps1"
#         - key:      "v2"
#           options:  "-fstype=nfs,soft,nfsvers=4,ro"
#           location: "nfs.example.com:/exports/apps2"
#         - key:      "latest"
#           options:  "-fstype=nfs,soft,nfsvers=4,ro"
#           location: "nfs.example.com:/exports/apps3"
#
# @author https://github.com/simp/pupmod-simp-autofs/graphs/contributors
#
class autofs (
  Integer                         $timeout                        = 600, #default?
  Optional[Integer]               $master_wait                    = undef,
  Optional[Integer]               $negative_timeout               = undef,
  Boolean                         $mount_verbose                  = false,
  Optional[Integer]               $mount_wait                     = undef,
  Optional[Integer]               $umount_wait                    = undef,
  Boolean                         $browse_mode                    = false,
  Integer[3,4]                    $mount_nfs_default_protocol     = 4,
  Boolean                         $append_options                 = true,
  Autofs::Logging                 $logging                        = 'none',
  Boolean                         $force_standard_program_map_env = false,
  Optional[Integer]               $map_hash_table_size            = undef,
  Boolean                         $use_hostname_for_mounts        = false,
  Boolean                         $disable_not_found_message      = false,
  Optional[Integer]               $sss_master_map_wait            = undef,
  Boolean                         $use_mount_request_log_id       = false,
  Optional[Array[Simplib::Uri,1]] $ldap_uri                       = undef,
  Optional[Integer]               $ldap_timeout                   = undef,
  Optional[Integer]               $ldap_network_timeout           = undef,
  Optional[Array[String,1]]       $search_base                    = undef,
  Optional[String]                $map_object_class               = undef,
  Optional[String]                $entry_object_class             = undef,
  Optional[String]                $map_attribute                  = undef,
  Optional[String]                $entry_attribute                = undef,
  Optional[String]                $value_attribute                = undef,
  Stdlib::Absolutepath            $auth_conf_file                 = '/etc/autofs_ldap_auth.conf',
  Hash                            $custom_autofs_conf_options     = {},
  Boolean                         $automount_use_misc_device      = true,
  Optional[String]                $automount_options              = undef,
  Stdlib::Absolutepath            $master_conf_dir                = '/etc/auto.master.simp.d',
  Array[Stdlib::Absolutepath]     $master_include_dirs            = [ '/etc/auto.master.d' ],
  Stdlib::Absolutepath            $maps_dir                       = '/etc/autofs.maps.simp.d',
  Hash[String,Autofs::Mapspec]    $maps                           = {},
  String                          $samba_package_ensure           = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' }),
  String                          $autofs_package_ensure          = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' }),
  Boolean                         $ldap                           = simplib::lookup('simp_options::ldap', { 'default_value' => false }),
  Variant[Enum['simp'],Boolean]   $pki                            = simplib::lookup('simp_options::pki', { 'default_value' => false })
) {

  include 'autofs::install'
  include 'autofs::config'
  include 'autofs::service'

  Class['autofs::install'] -> Class['autofs::config']
  Class['autofs::config'] ~> Class['autofs::service']
}
