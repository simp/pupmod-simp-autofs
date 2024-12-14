require 'spec_helper'

# Testing private autofs::config class via autofs class
describe 'autofs' do
  describe 'private autofs::config' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }

        context 'with default autofs parameters' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('autofs::config') }
          it {
            is_expected.to create_file('/etc/autofs.conf').with({
                                                                  owner: 'root',
            group: 'root',
            mode: '0644',
            content: <<~EOM
              # This file is managed by Puppet (simp-autofs module). Changes will be
              # overwritten at the next Puppet run.
              [autofs]

              timeout = 600
              mount_verbose = no
              browse_mode = no
              mount_nfs_default_protocol = 4
              append_options = yes
              logging = none
              force_standard_program_map_env = no
              use_hostname_for_mounts = no
              disable_not_found_message = no
              use_mount_request_log_id = no
            EOM
                                                                })
          }

          it {
            is_expected.to create_file('/etc/sysconfig/autofs').with({
                                                                       owner: 'root',
            group: 'root',
            mode: '0644',
            content: <<~EOM
              # This file is managed by Puppet (simp-autofs module). Changes will be
              # overwritten at the next Puppet run.
              USE_MISC_DEVICE="yes"
            EOM
                                                                     })
          }

          it {
            is_expected.to create_file('/etc/auto.master').with({
                                                                  owner: 'root',
            group: 'root',
            mode: '0644',
            content: <<~EOM
              # This file is managed by Puppet (simp-autofs module). Changes will be
              # overwritten at the next Puppet run.

              # This directory is managed by by simp-autofs.
              # - Unmanaged files in this directory will be removed.
              # - No other included directories are managed by simp-autofs.
              +dir:/etc/auto.master.simp.d

              +dir:/etc/auto.master.d
            EOM
                                                                })
          }

          it {
            is_expected.to create_file('/etc/auto.master.simp.d').with({
                                                                         ensure: 'directory',
            owner: 'root',
            group: 'root',
            mode: '0640',
            seltype: 'etc_t',
            recurse: true,
            purge: true
                                                                       })
          }

          it {
            is_expected.to create_file('/etc/autofs.maps.simp.d').with({
                                                                         ensure: 'directory',
            owner: 'root',
            group: 'root',
            mode: '0640',
            recurse: true,
            purge: true
                                                                       })
          }

          it { is_expected.not_to create_class('autofs::ldap_auth') }
        end

        context 'with ldap=false and optional parameters' do
          let(:params) do
            {
              ldap: false,
           master_wait: 10,
           negative_timeout: 20,
           mount_wait: 30,
           umount_wait: 40,
           map_hash_table_size: 4096,
           sss_master_map_wait: 50
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('autofs::config') }
          it {
            is_expected.to create_file('/etc/autofs.conf').with({
                                                                  owner: 'root',
            group: 'root',
            mode: '0644',
            content: <<~EOM
              # This file is managed by Puppet (simp-autofs module). Changes will be
              # overwritten at the next Puppet run.
              [autofs]

              timeout = 600
              master_wait = 10
              negative_timeout = 20
              mount_verbose = no
              mount_wait = 30
              umount_wait = 40
              browse_mode = no
              mount_nfs_default_protocol = 4
              append_options = yes
              logging = none
              force_standard_program_map_env = no
              map_hash_table_size = 4096
              use_hostname_for_mounts = no
              disable_not_found_message = no
              sss_master_map_wait = 50
              use_mount_request_log_id = no
            EOM
                                                                })
          }
        end

        context 'with ldap=true and default ldap-related parameters' do
          let(:params) { { ldap: true } }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('autofs::config') }
          it { is_expected.to create_class('autofs::ldap_auth') }
          it {
            is_expected.to create_file('/etc/autofs.conf').with({
                                                                  owner: 'root',
            group: 'root',
            mode: '0644',
            content: <<~EOM
              # This file is managed by Puppet (simp-autofs module). Changes will be
              # overwritten at the next Puppet run.
              [autofs]

              timeout = 600
              mount_verbose = no
              browse_mode = no
              mount_nfs_default_protocol = 4
              append_options = yes
              logging = none
              force_standard_program_map_env = no
              use_hostname_for_mounts = no
              disable_not_found_message = no
              use_mount_request_log_id = no
              auth_conf_file = /etc/autofs_ldap_auth.conf
            EOM
                                                                })
          }
        end

        context 'with ldap=true and optional ldap-related parameters' do
          let(:params) do
            {
              ldap: true,
           ldap_uri: [
             'ldaps://ldap1.example.com',
             'ldaps://ldap2.example.com',
           ],
           ldap_timeout: 10,
           ldap_network_timeout: 20,
           search_base: [ 'cn=automount,dc=example,dc=com' ],
           map_object_class: 'automountMap',
           entry_object_class: 'automount',
           map_attribute: 'automountMapName',
           entry_attribute: 'automountKey',
           value_attribute: 'automountInformation'
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('autofs::config') }
          it { is_expected.to create_class('autofs::ldap_auth') }
          it {
            is_expected.to create_file('/etc/autofs.conf').with({
                                                                  owner: 'root',
            group: 'root',
            mode: '0644',
            content: <<~EOM
              # This file is managed by Puppet (simp-autofs module). Changes will be
              # overwritten at the next Puppet run.
              [autofs]

              timeout = 600
              mount_verbose = no
              browse_mode = no
              mount_nfs_default_protocol = 4
              append_options = yes
              logging = none
              force_standard_program_map_env = no
              use_hostname_for_mounts = no
              disable_not_found_message = no
              use_mount_request_log_id = no
              ldap_uri = ldaps://ldap1.example.com
              ldap_uri = ldaps://ldap2.example.com
              ldap_timeout = 10
              ldap_network_timeout = 20
              search_base = cn=automount,dc=example,dc=com
              map_object_class = automountMap
              entry_object_class = automount
              map_attribute = automountMapName
              entry_attribute = automountKey
              value_attribute = automountInformation
              auth_conf_file = /etc/autofs_ldap_auth.conf
            EOM
                                                                })
          }
        end

        context 'with custom_autofs_conf_options set' do
          let(:params) do
            {
              custom_autofs_conf_options: {
                'some'    => 'future',
                'options' => 'tbd'
              }
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('autofs::config') }
          it {
            is_expected.to create_file('/etc/autofs.conf').with_content(
            <<~EOM,
              # This file is managed by Puppet (simp-autofs module). Changes will be
              # overwritten at the next Puppet run.
              [autofs]

              timeout = 600
              mount_verbose = no
              browse_mode = no
              mount_nfs_default_protocol = 4
              append_options = yes
              logging = none
              force_standard_program_map_env = no
              use_hostname_for_mounts = no
              disable_not_found_message = no
              use_mount_request_log_id = no
              some = future
              options = tbd
            EOM
          )
          }
        end

        context 'with automount_options set set' do
          let(:params) { { automount_options: '--random-multimount-selection' } }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('autofs::config') }
          it {
            is_expected.to create_file('/etc/sysconfig/autofs').with_content(
            <<~EOM,
              # This file is managed by Puppet (simp-autofs module). Changes will be
              # overwritten at the next Puppet run.
              USE_MISC_DEVICE="yes"
              OPTIONS="--random-multimount-selection"
            EOM
          )
          }
        end

        context 'with maps set' do
          let(:params) do
            {
              maps: {
                'apps' => {
                  'mount_point' => '/net/apps',
                  'mappings'    => [
                    {
                      'key'      => 'v1',
                      'location' => '1.2.3.4:/exports/apps1'
                    },
                    {
                      'key'      => 'v2',
                      'options'  => '-fstype=nfs,soft,nfsvers=4,ro',
                      'location' => '1.2.3.5:/exports/apps2'
                    },
                    {
                      'key'      => 'latest',
                      'location' => '1.2.3.6:/exports/apps3'
                    },
                  ]
                },
                'data' => {
                  'mount_point' => '/-',
                  'mappings'    => {
                    'key'      => '/net/data',
                    'location' => '1.2.3.4:/exports/data'
                  }
                },
                'home' => {
                  'mount_point'    => '/home',
                  'master_options' => 'strictexpire --strict',
                  'mappings'       => [ {
                    'key'      => '*',
                    'options'  => '-fstype=nfs,soft,nfsvers=4,ro',
                    'location' => '1.2.3.4:/exports/home/&'
                  } ]
                }
              }
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('autofs::config') }
          it {
            is_expected.to create_autofs__map('apps').with({
                                                             mount_point: params[:maps]['apps']['mount_point'],
            mappings: params[:maps]['apps']['mappings'],
                                                           })
          }

          it {
            is_expected.to create_autofs__map('data').with({
                                                             mount_point: params[:maps]['data']['mount_point'],
            mappings: params[:maps]['data']['mappings'],
                                                           })
          }

          it {
            is_expected.to create_autofs__map('home').with({
                                                             mount_point: params[:maps]['home']['mount_point'],
            master_options: params[:maps]['home']['master_options'],
            mappings: params[:maps]['home']['mappings'],
                                                           })
          }
        end
      end
    end
  end
end
