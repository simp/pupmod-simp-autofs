require 'spec_helper'

describe 'autofs::map::master' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'stuff' }

      context 'with minimal parameters including mount_point' do
        let(:params) do
          {
            mount_point: '/my/stuff',
            map_name: '/etc/autofs.maps.simp.d/bob',
          }
        end

        it do
          if Puppet[:strict] == :error
            is_expected.to compile.and_raise_error(%r{\bautofs::map::master is deprecated\.})
          else
            is_expected.to compile.with_all_deps
            is_expected.to contain_autofs__masterfile(title).with(
              mount_point: params[:mount_point],
              map: params[:map_name],
            )
          end
        end
      end

      context 'with legacy map location' do
        let(:params) do
          {
            mount_point: '/my/stuff',
            map_name: '/etc/autofs/bob',
          }
        end

        let(:converted_map_name) { '/etc/autofs.maps.simp.d/bob' }

        it do
          if Puppet[:strict] == :error
            is_expected.to compile.and_raise_error(%r{\bautofs::map::master is deprecated\.})
          else
            is_expected.to compile.with_all_deps
            is_expected.to contain_autofs__masterfile(title).with(
              mount_point: params[:mount_point],
              map: converted_map_name,
            )
          end
        end
      end

      context 'with a map_type specified' do
        let(:params) do
          {
            mount_point: '/my/stuff',
            map_name: '/etc/bob',
            map_type: 'file',
          }
        end

        it do
          if Puppet[:strict] == :error
            is_expected.to compile.and_raise_error(%r{\bautofs::map::master is deprecated\.})
          else
            is_expected.to compile.with_all_deps
            is_expected.to contain_autofs__masterfile(title).with(
              mount_point: params[:mount_point],
              map: params[:map_name],
              map_type: params[:map_type],
            )
          end
        end
      end

      context 'with content specified' do
        let(:params) do
          {
            content: "/mnt/apps ldap:ou=auto.indirect,dc=example,dc=com\n",
          }
        end

        let(:auto_master_entry_file) { "/etc/auto.master.simp.d/#{title}.autofs" }

        it do
          if Puppet[:strict] == :error
            is_expected.to compile.and_raise_error(%r{\bautofs::map::master is deprecated\.})
          else
            is_expected.to compile.with_all_deps
            is_expected.to contain_file(auto_master_entry_file).with_content(params[:content])
            is_expected.to contain_file(auto_master_entry_file).that_notifies('Exec[autofs_reload]')
          end
        end
      end

      context 'errors' do
        context 'no parameters set' do
          let(:params) { {} }

          it { is_expected.not_to compile.with_all_deps }
        end

        context 'only map_name set' do
          let(:params) { { map_name: 'oops' } }

          it { is_expected.not_to compile.with_all_deps }
        end
      end
    end
  end
end
