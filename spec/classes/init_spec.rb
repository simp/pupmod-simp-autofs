require 'spec_helper'

describe 'autofs' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        base_facts = facts.merge({:spec_title => description})

        describe 'base' do
          let(:facts) { base_facts }

          it { is_expected.to create_class('autofs') }
          it { is_expected.to contain_class('nfs') }
          it { is_expected.to contain_class('autofs::ldap_auth') }
          it { is_expected.to contain_package('nfs-utils').that_comes_before('Package[autofs]') }
        end

        describe 'no_nfs' do
          xfacts = base_facts.dup
          xfacts[:spec_title] = 'autofs/no_nfs'
          let(:facts) {xfacts}
          it { is_expected.not_to contain_package('nfs-utils').that_comes_before('Package[autofs]') }
        end

        describe 'no_ldap_auth_conf_file' do
          facts = base_facts.dup
          facts[:spec_title] = 'autofs/no_ldap_auth_conf_file'
          let(:facts) {facts}

          it { is_expected.not_to contain_class('autofs::ldap_auth') }
        end
      end
    end
  end
end
