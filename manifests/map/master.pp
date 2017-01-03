# Add an entry to the ``/etc/auto.master`` map
#
# If you're using the ``autofs::map::entry`` define, remember that the
# ``$target`` variable translates to '/etc/autofs/$target.map' which is what
# you should enter for ``$map`` below.
#
# @see auto.master(5)
#
# @param mount_point
#   See auto.master(5) -> FORMAT -> mount-point
#
#   * Required unless ``$content`` is set
#
# @param map_name
#   See auto.master(5) -> FORMAT -> map
#
#   * Required unless ``$content`` is set
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
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
#
define autofs::map::master (
  Optional[Stdlib::Absolutepath] $mount_point = undef,
  Optional[String]               $map_name    = undef,
  Optional[Autofs::Maptype]      $map_type    = undef,
  Optional[Enum['sun','hesiod']] $map_format  = undef,
  Optional[String]               $options     = undef,
  Optional[String]               $content     = undef
) {

  if $content {
    $_content = $content
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
    elsif $map_type {
      if $map_name !~ String {
        fail('"$map_name" must be a String when "$map_type" is not "file" or "program"')
      }
    }

    $_content = template("${module_name}/etc/auto.master.erb")
  }

  ensure_resource('concat','/etc/auto.master',
    {
      owner          => 'root',
      group          => 'root',
      mode           => '0640',
      ensure_newline => true,
      warn           => true,
      notify         => Class['autofs::service']
    }
  )

  concat::fragment { "autofs_master_${name}":
    target  => '/etc/auto.master',
    content => $_content
  }
}
