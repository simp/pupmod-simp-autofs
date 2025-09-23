require 'spec_helper'

# Testing private autofs::ldap_auth class via autofs class
describe 'autofs' do
  describe 'private autofs::ldap_auth' do
    let(:params) { { ldap: true } }

    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }

        context 'with default parameters' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('autofs::ldap_auth') }
          it {
            is_expected.to create_file('/etc/autofs_ldap_auth.conf').with(
              owner: 'root',
              group: 'root',
              mode: '0600',
              content: <<~EOM,
                <?xml version="1.0" ?>
                <autofs_ldap_sasl_conf
                  usetls="yes"
                  tlsrequired="yes"
                  authrequired="yes"
                  authtype="LOGIN"
                />
              EOM
            )
          }
        end

        context 'with simp_options::ldap* parameters set' do
          let(:params) { {} }
          let(:hieradata) { 'simp_options_ldap' }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('autofs::ldap_auth') }
          it {
            is_expected.to create_file('/etc/autofs_ldap_auth.conf').with_content(<<~EOM)
              <?xml version="1.0" ?>
              <autofs_ldap_sasl_conf
                usetls="yes"
                tlsrequired="yes"
                authrequired="yes"
                authtype="LOGIN"
                user="LDAPBindUser"
                secret="LDAPBindPassword"
              />
            EOM
          }
        end

        context 'with all but encoded_secret optional parameters set' do
          let(:hieradata) { 'autofs_ldap_auth_most_optional_params' }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('autofs::ldap_auth') }
          it {
            is_expected.to create_file('/etc/autofs_ldap_auth.conf').with_content(<<~EOM)
              <?xml version="1.0" ?>
              <autofs_ldap_sasl_conf
                usetls="yes"
                tlsrequired="yes"
                authrequired="yes"
                authtype="LOGIN"
                user="LDAPUser"
                secret="LDAPPass"
                clientprinc="autofsclient/host.example.com@EXAMPLE.COM"
                credentialcache="/path/to/cache"
              />
            EOM
          }
        end

        context 'with all optional parameters set' do
          let(:hieradata) { 'autofs_ldap_auth_all_optional_params' }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('autofs::ldap_auth') }
          it {
            is_expected.to create_file('/etc/autofs_ldap_auth.conf').with_content(<<~EOM)
              <?xml version="1.0" ?>
              <autofs_ldap_sasl_conf
                usetls="yes"
                tlsrequired="yes"
                authrequired="yes"
                authtype="LOGIN"
                user="LDAPUser"
                encoded_secret="TERBUFBhc3M="
                clientprinc="autofsclient/host.example.com@EXAMPLE.COM"
                credentialcache="/path/to/cache"
              />
            EOM
          }
        end

        context 'with authrequired set to a string' do
          let(:hieradata) { 'autofs_ldap_auth_authrequired' }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('autofs::ldap_auth') }
          it {
            is_expected.to create_file('/etc/autofs_ldap_auth.conf').with_content(
              %r{authrequired="simple"},
            )
          }
        end

        context 'with authtype=EXTERNAL and autofs::pki=false' do
          let(:hieradata) { 'autofs_ldap_auth_authtype_external' }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('autofs::ldap_auth') }
          it {
            is_expected.to create_file('/etc/autofs_ldap_auth.conf').with_content(<<~EOM)
              <?xml version="1.0" ?>
              <autofs_ldap_sasl_conf
                usetls="yes"
                tlsrequired="yes"
                authrequired="yes"
                authtype="EXTERNAL"
                external_cert="/etc/pki/simp_apps/autofs/x509/public/foo.example.com.pub"
                external_key="/etc/pki/simp_apps/autofs/x509/private/foo.example.com.pem"
              />
            EOM
          }

          it { is_expected.to create_class('autofs::config::pki') }

          # autofs::config::pki class is also trivial, so test it here
          it { is_expected.not_to create_pki__copy('autofs') }
        end

        context 'with authtype=EXTERNAL and autofs::pki != false' do
          let(:hieradata) { 'autofs_ldap_auth_authtype_external' }
          let(:params) do
            {
              ldap: true,
              pki: 'simp',
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('autofs::ldap_auth') }
          it { is_expected.to create_class('autofs::config::pki') }

          # autofs::config::pki class is also trivial, so test it here
          it {
            is_expected.to create_pki__copy('autofs').with(
              source: '/etc/pki/simp/x509',
              pki: 'simp',
            )
          }
        end
      end
    end
  end
end
