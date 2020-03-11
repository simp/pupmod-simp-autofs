require 'spec_helper'

describe 'autofs::map::master' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'stuff' }

      context  'with minimal parameters including mount_point' do
        let(:params) {{
          :mount_point => '/my/stuff',
          :map_name    => 'bob'
        }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_autofs__masterfile(title).with( {
          :mount_point => params[:mount_point],
          :map         => params[:map_name]
        } ) }
      end

      context 'with a map_type specified' do
        let(:params) {{
          :mount_point => '/my/stuff',
          :map_name    => '/bob',
          :map_type    => 'file'
        }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_autofs__masterfile(title).with( {
          :mount_point => params[:mount_point],
          :map         => params[:map_name],
          :map_type    => params[:map_type]
        } ) }
      end

      context 'with content specified' do
        let(:params) {{
          :content => "/mnt/apps ldap:ou=auto.indirect,dc=example,dc=com\n"
        }}

        let(:auto_master_entry_file) { "/etc/auto.master.simp.d/#{title}.autofs" }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file(auto_master_entry_file).with_content(
          params[:content]) }

        it { is_expected.to contain_file(auto_master_entry_file).that_notifies('Exec[autofs_reload]') }
      end

      context 'errors' do
        context 'no parameters set' do
          let(:params) {{ }}

          it { is_expected.to_not compile.with_all_deps }
        end

        context 'only map_name set' do
          let(:params) {{ :map_name => 'oops' }}

          it { is_expected.to_not compile.with_all_deps }
        end
      end
    end
  end
end
