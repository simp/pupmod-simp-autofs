require 'spec_helper'

describe 'autofs::map::master' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:pre_condition) {
          'include "autofs"'
        }

        let(:facts) { facts }
        let(:title) { 'wildcard-stuff' }
        let(:params) {{
          :mount_point => '/my/stuff',
          :map_name    => 'bob'
        }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_concat('/etc/auto.master').that_notifies('Class[autofs::service]') }
        it { is_expected.to contain_concat__fragment("autofs_master_#{title}").with_content(%r{#{params[:mount_point]}}) }

        context 'with a map_type specified' do
          let(:params) {{
            :mount_point => '/my/stuff',
            :map_name    => '/bob',
            :map_type    => 'file'
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_concat__fragment("autofs_master_#{title}").with_content(%r{#{params[:mount_point]}\s+file:#{params[:map_name]}}) }
        end
      end
    end
  end
end
