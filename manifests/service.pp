# @summary Manage autofs service
#
# @author https://github.com/simp/pupmod-simp-autofs/graphs/contributors
#
class autofs::service {
  service { 'autofs':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

  exec { 'autofs_reload':
    command     => '/usr/bin/systemctl reload autofs',
    refreshonly => true
  }

  Service['autofs'] -> Exec['autofs_reload']
}
