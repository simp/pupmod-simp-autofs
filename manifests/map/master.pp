# == Define autofs::map::master
#
# Add an entry to the /etc/auto.master map.
# If you want to specify the entire file yourself, simply do not use
# this define. Instead, source the file of your choosing and notify
# the 'autofs' service.
#
# If you're using the autofs::map::entry define, remember that the
# $target variable translates to '/etc/autofs/$target.map' which is
# what you should enter for $map below.
#
# For additional details see auto.master(5).
#
# == Parameters
#
# [*mount_point*]
#   Type: Absolute Path
#   See auto.master(5) -> FORMAT -> mount-point
#
# [*map_name*]
#   Type: Varies
#     $map_type[file|program] => Absolute Path
#     $map_type[yp|nisplus|hesiod] => String
#     $map_type[ldap|ldaps] => LDAP DN
#   See auto.master(5) -> FORMAT -> map
#
# [*map_type*]
#   Type: [file|program|yp|nisplus|hesiod|ldap|ldaps|multi]
#   See auto.master(5) -> FORMAT -> map-type
#
# [*map_format*]
#   Type: [sun|hesiod]
#   See auto.master(5) -> FORMAT -> format
#
# [*options*]
#   Type: String
#   See auto.master(5) -> FORMAT -> options
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
define autofs::map::master (
  $mount_point,
  $map_name,
  $map_type = '',
  $map_format = '',
  $options = ''
  ) {

  if !defined(File['/etc/auto.master']) {
    concat_build { 'autofs_master':
      order  => ['*.map'],
      target => '/etc/auto.master'
    }

    file { '/etc/auto.master':
      ensure    => 'present',
      owner     => 'root',
      group     => 'root',
      mode      => '0640',
      subscribe => Concat_build['autofs_master'],
      notify    => Service['autofs']
    }
  }

  concat_fragment { "autofs_master+${name}.map":
    content => template('autofs/auto.master.erb')
  }

  validate_absolute_path($mount_point)
  if !empty($map_type) {
    validate_array_member($map_type,['file','program','yp','nisplus','hesiod','ldap','ldaps','multi'])
  }
  if !empty($map_format) {
    validate_array_member($map_format,['sun','hesiod'])
  }
}
