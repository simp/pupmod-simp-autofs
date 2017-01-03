# Add an entry to the map specified in ``$name``
#
# The map file will be created as ``/etc/autofs/$target.map``.
#
# You will need to create an appropriate ``map::master`` entry for this to be
# activated.
#
# @see autofs(5)
#
# @param name
#   In this case, ``$name`` is mapped to the ``key`` entry as described in
#   ``autofs(5)``
#
#   * The special wildcard entry ``*`` is specified by entering the name as
#     ``wildcard-<anything_unique>``
#
# @param target
#   The name (**not the full path**) of the map file under which you would like
#   this entry placed
#
#   * Required unless ``$content`` is set
#
# @param location
#   The location that should be mounted
#
#   * Required unless ``$content`` is set
#   * This should be the full path on the remote server
#       * Example: ``1.2.3.4:/my/files``
#   * See ``autofs(5)`` for details
#
# @param options
#   The NFS ``options`` that you would like to add to your map
#
# @param content
#   Use this content, without validation, ignoring all other options
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
#
define autofs::map::entry (
  Optional[String] $target   = undef,
  Optional[String] $location = undef,
  Optional[String] $options  = undef,
  Optional[String] $content  = undef
) {

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

  ensure_resource('concat',"/etc/autofs/${target}.map",
    {
      owner          => 'root',
      group          => 'root',
      mode           => '0640',
      ensure_newline => true,
      warn           => true,
      notify         => Class['autofs::service']
    }
  )

  concat::fragment { "autofs_${target}_${name}":
    target  => "/etc/autofs/${target}.map",
    content => $_content
  }
}
