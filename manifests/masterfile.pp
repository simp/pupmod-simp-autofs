# @summary Create a `$name.autofs` master entry file in `$autofs::master_conf_dir`
#
# This will only create the autofs master entry file.
#
# * If the map type is 'file' or unspecified, you will need to create the map
#   file, e.g. using `autofs::mapfile`.  Alternatively, use `autofs::map` which
#   will create both the master entry file and its map file.
# * If the map type is 'program', you will need to ensure the specified
#   executable is available and has the appropriate permissions.
#
# @see auto.master(5)
#
# @param name
#   Base name of the autofs master entry file excluding the path and the
#   `.autofs` suffix
#
#   * If `$name` has any whitespace or '/' characters, those characters will be
#     replaced with '__' in order to create a safe filename.
#
# @param mount_point
#   Base location for the autofs filesystem to be mounted
#
#   * Set to '/-' for direct maps
#   * Set to a fully-qualified path for indirect mounts
#   * See auto.master(5) -> FORMAT -> mount-point
#
# @param map
#   Name of the map to use
#
#   * See auto.master(5) -> FORMAT -> map
#   * Format of this String must match $map_type:
#
#     * $map_type of file|program => Absolute Path
#     * $map_type of yp|nisplus|hesiod  => String
#     * $map_type of ldap|ldaps         => LDAP DN
#
# @param map_type
#   Type of map used for this mount point
#
#   * When unspecified, autofs auto-detects the type.
#   * See auto.master(5) -> FORMAT -> map-type
#
# @param map_format
#   Format of the map data
#
#   * When unspecified, autofs assumes this is 'sun'
#   * See auto.master(5) -> FORMAT -> format
#
# @param options
#   Options for `mount` and/or `automount`
#
#   * See auto.master(5) -> FORMAT -> options
#
# @example Create an autofs master entry file for a direct file map
#   autofs::masterfile { 'data':
#     mount_point => '/-',
#     map         => '/etc/autofs.maps.simp.d/data'
#   }
#
# @example Create an autofs master entry file for an indirect file map
#   autofs::masterfile { 'home':
#     mount_point => '/home',
#     map         => '/etc/autofs.maps.simp.d/home'
#   }
#
# @example Create an autofs master entry file for a program map
#   autofs::masterfile { 'nfs4':
#     mount_point => '/nfs4',
#     map_type    => 'program',
#     map         => '/usr/sbin/fedfs-map-nfs4',
#     options     => 'nobind'
#   }
#
# @example Create an autofs master entry file for a ldap map with pre-configured LDAP server
#   autofs::masterfile { 'home':
#     mount_point => '/home',
#     map_type    => 'ldap',
#     map         => 'ou=auto.indirect,dc=example,dc=com'
#   }
#
# @author https://github.com/simp/pupmod-simp-autofs/graphs/contributors
#
define autofs::masterfile (
  Stdlib::Absolutepath           $mount_point,
  String                         $map,
  Optional[Autofs::Maptype]      $map_type   = undef,
  Optional[Enum['sun','hesiod']] $map_format = undef,
  Optional[String]               $options    = undef
) {

  include 'autofs'

  # Validate format of the $map String for the subset of cases that we can!
  if ($map_type in ['file','program']) {
    if $map !~ Stdlib::Absolutepath {
      fail('"$map" must be a Stdlib::Absolutepath when "$map_type" is not specified or is "file" or "program"')
    }
  }

  $_content = epp("${module_name}/etc/auto.master.simp.d/entry.autofs.epp", {
    'mount_point' => $mount_point,
    'map'         => $map,
    'map_type'    => $map_type,
    'map_format'  => $map_format,
    'options'     => $options
  })

  $_safe_name = regsubst(regsubst($name, '^/', ''), '(/|\s)', '__', 'G')
  file { "${autofs::master_conf_dir}/${_safe_name}.autofs":
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => $_content,
    notify  => Exec['autofs_reload']
  }
}
