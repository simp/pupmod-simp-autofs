require 'spec_helper'
require 'pp'

describe 'autofs' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts.merge({:haveged_startup_provider => 'systemd'}) }
        let(:hieradata) { class_name }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('autofs') }
        it { is_expected.to create_file('/etc/sysconfig/autofs') }
        it { is_expected.to contain_class('autofs::install') }
        it { is_expected.to contain_class('autofs::service') }
        it { is_expected.to_not contain_class('autofs::ldap_auth') }

        context 'when using LDAP' do
          let(:params){{
            :ldap => true
          }}

          it { is_expected.to compile.with_all_deps }
        end
      end
    end
  end
end
