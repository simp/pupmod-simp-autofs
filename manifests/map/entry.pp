# == Define autofs::map::entry
#
# Add an entry to the map specified in $name.
#
# The map file will be created as /etc/autofs/$target.map.
#
# You will need to create an appropriate map::master entry for this to
# be activated.
#
# For additional details see autofs(5)
#
# == Parameters
#
# [*name*]
#   Type: String
#   In this case, $name is mapped to the 'key' entry as described in
#   autofs(5). However, the special wildcard entry '*' is specified by
#   entering the name as 'wildcard-<anything_unique>'.
#
# [*target*]
#   Type: String
#   The name of the map file under which you would like this entry
#   placed.
#
# [*ensure*]
#   Type: ['present','absent']
#   Whether to add or delete the target file.
#
# [*options*]
#   Type: String
#   The NFS options that you would like to add to your map.
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
define autofs::map::entry (
  $target,
  $location,
  $ensure = 'present',
  $options = ''
) {

  $_name = regsubst($name,'/','_','G')

  # Convert the target '/' to '_' and delete the first one for readability
  $_target = regsubst(regsubst($target,'/','_','G'), '_', '')

  if $name =~ /^wildcard(-|$)/ {
    $_key = '*'
  }
  else {
    $_key = $name
  }

  # This ensures that this define will only do this once.
  if !defined(File["/etc/autofs/${_target}.map"]) {
    concat_build { "autofs_${_target}":
      order  => ['*.map'],
      target => "/etc/autofs/${_target}.map"
    }

    file { "/etc/autofs/${_target}.map":
      ensure    => $ensure,
      owner     => 'root',
      group     => 'root',
      mode      => '0640',
      audit     => 'content',
      subscribe => Concat_build["autofs_${_target}"],
      notify    => Service['autofs']
    }
  }

  concat_fragment { "autofs_${_target}+${_name}.map":
    content => "${_key}\t${options}\t${location}\n"
  }
}
