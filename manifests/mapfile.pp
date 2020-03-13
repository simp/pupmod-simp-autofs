# @summary Create an autofs map file
#
# You will need to create an corresponding auto.master entry file, e.g. using
# `autofs::masterfile`, for this to be activated.  Alternatively, use
# `autofs::map`, which will create both the master entry file and its map file
# for you.
#
# @see autofs(5)
#
# @param name
#   Base name of the map excluding the path and the `.map` suffix
#
#   * If `$name` has any whitespace or '/' characters, those characters will be
#     replaced with '__' in order to create a safe filename.
#
# @param mappings
#   Single direct mapping or one or more indirect mappings
#
#   * Each mapping specifies a key, a location, and any `automount` and/or
#     `mount` options.
#   * Any change to a direct map will trigger a reload of the autofs service.
#     This is not necessary for an indirect map.
#
# @param maps_dir
#   When unset defaults to `$autofs::maps_dir`
#
# @example Create an autofs map file for a direct map
#   autofs::mapfile {'data':
#     mappings => {
#       'key'      => '/net/data',
#       'options'  => '-fstype=nfs,soft,nfsvers=4,ro',
#       'location' => '1.2.3.4:/exports/data'
#     }
#   }
#
# @example Create an autofs map file for an indirect map with wildcard key
#   autofs::mapfile { 'home':
#     mappings => [
#       {
#         'key'      => '*',
#         'options'  => '-fstype=nfs,soft,nfsvers=4,rw',
#         'location' => '1.2.3.4:/exports/home/&'
#       }
#     ]
#   }
#
# @example Create an autofs map file for an indirect map with mutiple keys
#   autofs::mapfile { 'apps':
#     mappings => [
#       {
#         'key'      => 'v1',
#         'options'  => '-fstype=nfs,soft,nfsvers=4,rw',
#         'location' => '1.2.3.4:/exports/apps1'
#       },
#       {
#         'key'      => 'v2',
#         'options'  => '-fstype=nfs,soft,nfsvers=4,rw',
#         'location' => '1.2.3.4:/exports/apps2'
#       },
#       {
#         'key'      => 'latest',
#         'options'  => '-fstype=nfs,soft,nfsvers=4,rw',
#         'location' => '1.2.3.5:/exports/apps3'
#       }
#     ]
#   }
#
# @author https://github.com/simp/pupmod-simp-autofs/graphs/contributors
#
define autofs::mapfile (
  Variant[Autofs::Directmapping, Array[Autofs::Indirectmapping,1]] $mappings,
  Optional[Stdlib::Absolutepath]                                   $maps_dir = undef

) {

  include 'autofs'

  if $maps_dir =~ Undef {
    $_maps_dir = $autofs::maps_dir
  } else {
    $_maps_dir = $maps_dir
  }

  $_safe_name = regsubst(regsubst($name, '^/', ''), '(/|\s)', '__', 'G')
  $_map_file = "${_maps_dir}/${_safe_name}.map"
  file { $_map_file:
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => epp("${module_name}/etc/autofs.maps.simp.d/map.epp", {
      'mappings' => $mappings} )
  }

  if $mappings =~ Autofs::Directmapping {
    # Direct map changes are only picked up if the autofs service is reloaded
    File[$_map_file] ~> Exec['autofs_reload']
  }
}
