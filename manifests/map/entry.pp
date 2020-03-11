# @summary Add an entry to the map specified in `$name`
#
# THIS IS DEPRECATED.  Use `autofs::mapfile` or `autofs::map` instead.
#
# The map file will be created as `${autofs::maps_dir}/$target.map`.
#
# You will need to create an appropriate `autofs::masterfile` entry for
# this to be activated.
#
# @see autofs(5)
#
# @param name
#   In this case, `$name` is mapped to the `key` entry as described in
#   `autofs(5)`
#
#   * The special wildcard entry `*` is specified by entering the name as
#     `wildcard-<anything_unique>`
#
# @param target
#   The name (**not the full path**) of the map file under which you would like
#   this entry placed
#
#   * Required unless `$content` is set
#
# @param location
#   The location that should be mounted
#
#   * Required unless `$content` is set
#   * This should be the full path on the remote server
#       * Example: `1.2.3.4:/my/files`
#   * See `autofs(5)` for details
#
# @param options
#   The NFS `options` that you would like to add to your map
#
# @param content
#   Use this content, without validation, ignoring all other options
#
# @author https://github.com/simp/pupmod-simp-autofs/graphs/contributors
#
define autofs::map::entry (
  Optional[String] $target   = undef,
  Optional[String] $location = undef,
  Optional[String] $options  = undef,
  Optional[String] $content  = undef
) {

  deprecation('autofs::map::entry',
    'autofs::map::entry is deprecated. Use autofs::mapfile or autofs::map instead')

  simplib::assert_optional_dependency($module_name, 'puppetlabs/concat')

  if $name =~ /^wildcard(-|$)/ {
    $_key = '*'
  }
  else {
    $_key = $name
  }

  if $content {
    $_content = $content
  }
  else {
    if !($target and $location) {
      fail('You must specify either "$content" or "$target" and "$location"')
    }

    $_content = "${_key}\t${options}\t${location}"
  }

  # Make sure the map file in the old location is removed. We can't remove the
  # /etc/autofs directory, because it was not fully managed.  Specifically, the
  # file resource had a bug whereby it was using the purge attribute without
  # the recurse attribute.  So, files not managed by Puppet may be present.
  file { "/etc/autofs/${target}.map":
    ensure => absent
  }

  include 'autofs'

  ensure_resource('concat',"${autofs::maps_dir}/${target}.map",
    {
      owner          => 'root',
      group          => 'root',
      mode           => '0640',
      ensure_newline => true,
      warn           => true,
      # This is only needed for direct maps, but we don't know
      # what kind of map this is.
      notify         => Exec['autofs_reload']
    }
  )

  concat::fragment { "autofs_${target}_${name}":
    target  => "${autofs::maps_dir}/${target}.map",
    content => $_content
  }
}
