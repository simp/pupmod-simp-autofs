require 'spec_helper'

describe 'autofs::masterfile' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'my_stuff' }
      let(:file_map) { "/etc/autofs.maps.d/#{title}" }
      let(:auto_master_entry_file) { "/etc/auto.master.simp.d/#{title}.autofs" }

      context 'with default parameters for a direct map' do
        let(:params) do
          {
            mount_point: '/-',
         map: file_map,
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('autofs') }
        it { is_expected.to contain_autofs__masterfile(title) }
        it {
          is_expected.to contain_file(auto_master_entry_file).with({
                                                                     owner: 'root',
          group: 'root',
          mode: '0640',
          content: <<~EOM,
            # This file is managed by Puppet (simp-autofs module).  Changes will be
            # overwritten at the next puppet run.
            /-  /etc/autofs.maps.d/my_stuff
          EOM
                                                                   })
        }

        it { is_expected.to contain_file(auto_master_entry_file).that_notifies('Exec[autofs_reload]') }
      end

      context 'with default parameters for a indirect map' do
        let(:params) do
          {
            mount_point: '/net/my_stuff',
         map: file_map,
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('autofs') }
        it { is_expected.to contain_autofs__masterfile(title) }
        it {
          is_expected.to contain_file(auto_master_entry_file).with_content(
          <<~EOM,
            # This file is managed by Puppet (simp-autofs module).  Changes will be
            # overwritten at the next puppet run.
            /net/my_stuff  /etc/autofs.maps.d/my_stuff
          EOM
        )
        }
      end

      context 'with map_type specified but map_format unspecified' do
        let(:title) { 'home' }
        let(:params) do
          {
            mount_point: '/home',
         map: '/some/exec/to/run',
         map_type: 'program',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_file(auto_master_entry_file).with_content(
          <<~EOM,
            # This file is managed by Puppet (simp-autofs module).  Changes will be
            # overwritten at the next puppet run.
            /home  program:/some/exec/to/run
          EOM
        )
        }
      end

      context 'with all optional parameters specified' do
        let(:title) { 'home' }
        let(:params) do
          {
            mount_point: '/home',
         map: 'ou=auto.indirect,dc=example,dc=com',
         map_type: 'ldap',
         map_format: 'hesiod',
         options: 'strictexpire --strict',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it {
          is_expected.to contain_file(auto_master_entry_file).with_content(
          <<~EOM,
            # This file is managed by Puppet (simp-autofs module).  Changes will be
            # overwritten at the next puppet run.
            /home  ldap,hesiod:ou=auto.indirect,dc=example,dc=com  strictexpire --strict
          EOM
        )
        }
      end

      context 'with / in title' do
        let(:title) { '/some/path/my_stuff' }
        let(:params) do
          {
            mount_point: '/net/my_stuff',
         map: file_map,
          }
        end

        it { is_expected.to compile.with_all_deps }
        it 'replaces / characters' do
          file = '/etc/auto.master.simp.d/some__path__my_stuff.autofs'
          is_expected.to contain_file(file)
        end
      end

      context 'with whitespace in title' do
        let(:title) { 'this is my_stuff' }
        let(:params) do
          {
            mount_point: '/net/my_stuff',
         map: file_map,
          }
        end

        it { is_expected.to compile.with_all_deps }
        it 'replaces whitespace characters' do
          file = '/etc/auto.master.simp.d/this__is__my_stuff.autofs'
          is_expected.to contain_file(file)
        end
      end

      context 'with errors' do
        context 'with map_type=file and map that is not an absolute path' do
          let(:params) do
            {
              mount_point: 'my_stuff',
           map: file_map,
           map_type: 'file',
            }
          end

          it { is_expected.not_to compile.with_all_deps }
        end

        context 'with map_type=program and map that is not an absolute path' do
          let(:params) do
            {
              mount_point: 'my_stuff',
           map: '/some/exec/to/run',
           map_type: 'program',
            }
          end

          it { is_expected.not_to compile.with_all_deps }
        end
      end
    end
  end
end
