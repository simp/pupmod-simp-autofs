# @summary Add a `$name.autofs` master entry file to `$autofs::master_conf_dir`
#
# THIS IS DEPRECATED.  Use `autofs::masterfile` or `autofs::map` instead.
#
# @see auto.master(5)
#
# @param mount_point
#   See auto.master(5) -> FORMAT -> mount-point
#
#   * Required unless `$content` is set
#
# @param map_name
#   See auto.master(5) -> FORMAT -> map
#
#   * Required unless `$content` is set
#   * $map_type[file|program]      => Absolute Path
#   * $map_type[yp|nisplus|hesiod] => String
#   * $map_type[ldap|ldaps]        => LDAP DN
#
# @param map_type
#   See auto.master(5) -> FORMAT -> map-type
#
# @param map_format
#   See auto.master(5) -> FORMAT -> format
#
# @param options
#   See auto.master(5) -> FORMAT -> options
#
# @param content
#   Ignore all other parameters and use this content without validation
#
# @author https://github.com/simp/pupmod-simp-autofs/graphs/contributors
#
define autofs::map::master (
  Optional[Stdlib::Absolutepath] $mount_point = undef,
  Optional[String]               $map_name    = undef,
  Optional[Autofs::Maptype]      $map_type    = undef,
  Optional[Enum['sun','hesiod']] $map_format  = undef,
  Optional[String]               $options     = undef,
  Optional[String]               $content     = undef
) {

  deprecation('autofs::map::master',
    'autofs::map::master is deprecated. Use autofs::masterfile or autofs::map instead')

  include 'autofs'

  if $content {
    $_safe_name = regsubst($name, '(/|\s)', '__', 'G')

    file { "${autofs::master_conf_dir}/${_safe_name}.autofs":
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => $content,
      notify  => Exec['autofs_reload']
    }
  }
  else {
    if !($mount_point and $map_name) {
      fail('You must specify either "$content" or "$mount_point" and "$map_name"')
    }

    # map_name validation
    if $map_type in ['file','program'] {
      if $map_name !~ Stdlib::Absolutepath {
        fail('"$map_name" must be a Stdlib::Absolutepath when "$map_type" is "file" or "program"')
      }
    }

    if $map_name =~ /^\/etc\/autofs\// {
      $_map_name = "${autofs::maps_dir}/${basename($map_name)}"
      warning("Old configuration detected: Map file changed from ${map_name} to ${_map_name}")
    } else {
      $_map_name = $map_name
    }

    autofs::masterfile { $name:
      mount_point => $mount_point,
      map         => $_map_name,
      map_type    => $map_type,
      map_format  => $map_format,
      options     => $options
    }
  }
}
