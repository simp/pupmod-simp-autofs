require 'spec_helper'
require 'pp'

describe 'autofs' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts.merge({:haveged_startup_provider => 'Systemd'}) }
        let(:hieradata) { class_name }

        it { is_expected.to create_class('autofs') }
        it { is_expected.to contain_class('nfs') }
        it { is_expected.to contain_class('autofs::ldap_auth') }
        it { is_expected.to contain_package('nfs-utils').that_comes_before('Package[autofs]') }
        it { is_expected.to_not contain_exec('refresh autofs') }

        context 'with nfs and nfs::stunnel' do
          let(:hieradata) { 'use_stunnel' }
          it { is_expected.to contain_class('nfs') }
          it { is_expected.to contain_exec('refresh_autofs') }
        end

        context 'no_nfs' do
          let(:hieradata) { "#{class_name}_no_nfs" }
          it { is_expected.to_not contain_class('nfs') }
          it { is_expected.to_not contain_package('nfs-utils') }
          it { is_expected.to_not contain_exec('refresh autofs') }
        end

        describe 'no_ldap_auth_conf_file' do
          let(:hieradata) { "#{class_name}_no_ldap_auth_conf_file" }
          it { is_expected.not_to contain_class('autofs::ldap_auth') }
        end
      end
    end
  end
end
