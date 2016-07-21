require 'spec_helper'

describe 'autofs' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }
        let(:hieradata) { class_name }

        it { is_expected.to create_class('autofs') }
        it { is_expected.to contain_class('nfs') }
        it { is_expected.to contain_class('autofs::ldap_auth') }
        it { is_expected.to contain_package('nfs-utils').that_comes_before('Package[autofs]') }

        context 'no_nfs' do
          let(:hieradata) { "#{class_name}_no_nfs" }
          it { is_expected.not_to contain_package('nfs-utils') }
        end

        describe 'no_ldap_auth_conf_file' do
          let(:hieradata) { "#{class_name}_no_ldap_auth_conf_file" }
          it { is_expected.not_to contain_class('autofs::ldap_auth') }
        end
      end
    end
  end
end
