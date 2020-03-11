# @summary Manages `autofs` global configuration
#
# @api private
# @author https://github.com/simp/pupmod-simp-autofs/graphs/contributors
#
class autofs::config {
  assert_private()

  file { '/etc/autofs.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp("${module_name}/etc/autofs.conf.epp")
  }

  file { '/etc/sysconfig/autofs':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp("${module_name}/etc/sysconfig/autofs.epp")
  }

  file { '/etc/auto.master':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp("${module_name}/etc/auto.master.epp")
  }

  file { $autofs::master_conf_dir:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    # Needs to match the seltype of /etc/auto.master.d.  Will default to
    # seltype of /etc/auto.master (bin_t) if not set here.
    seltype => 'etc_t',
    recurse => true,
    purge   => true
  }

  file { $autofs::maps_dir:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    recurse => true,
    purge   => true
  }

  if $autofs::ldap {
    contain 'autofs::ldap_auth'
  }

  $autofs::maps.each |String $map_name, Autofs::Mapspec $map_spec| {
    autofs::map { $map_name:
      * => $map_spec
    }
  }
}
