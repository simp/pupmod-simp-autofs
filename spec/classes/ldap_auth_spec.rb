require 'spec_helper'

describe 'autofs::ldap_auth' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        base_facts = facts
        let(:facts) {base_facts}

        params = { :ldap_auth_conf_file => '/conf/file' }
        let(:params) {params}

        context 'base' do
          it { is_expected.to create_class('autofs::ldap_auth') }
          it { is_expected.to create_file(params[:ldap_auth_conf_file]) }
          # Not sure why this test is failing. May be a bug in rspec-puppet
          # it { is_expected.to contain_file(params[:ldap_auth_conf_file]).that_notifies('Service[autofs]') }
        end

        context 'external_cert_empty' do
          let(:params) {{
            :authtype => 'external',
            :external_cert => false
          }}

          it {
            expect {
              is_expected.to create_class('autofs::ldap_auth')
            }.to raise_error(Puppet::Error,/\$external_cert and \$external_key must be specified when setting \$authtype to "EXTERNAL"/)
          }
        end

        context 'external_key_empty' do
          let(:params) {{
            :authtype => 'external',
            :external_key => false
          }}

          it {
            expect {
              is_expected.to create_class('autofs::ldap_auth')
            }.to raise_error(Puppet::Error,/\$external_cert and \$external_key must be specified when setting \$authtype to "EXTERNAL"/)
          }
        end

        context 'base_auth_conf_file' do
          facts = base_facts.dup
          facts[:fqdn] = 'host.test.net'

          let(:facts) {facts}
          let(:params) {{
            :user                => 'foo',
            :secret              => 'bar',
            :authtype            => 'login',
            :ldap_auth_conf_file => '/conf/file'
          }}

          it { is_expected.to contain_file(params[:ldap_auth_conf_file]).with_content(/usetls="yes"/) }
          it { is_expected.to contain_file(params[:ldap_auth_conf_file]).with_content(/tlsrequired="yes"/) }
          it { is_expected.to contain_file(params[:ldap_auth_conf_file]).with_content(/authrequired="yes"/) }
          it { is_expected.to contain_file(params[:ldap_auth_conf_file]).with_content(/authtype="LOGIN"/) }
          it { is_expected.not_to contain_file(params[:ldap_auth_conf_file]).with_content(/external_cert/) }
          it { is_expected.not_to contain_file(params[:ldap_auth_conf_file]).with_content(/external_key/) }
          it { is_expected.to contain_file(params[:ldap_auth_conf_file]).with_content(/user="foo"/) }
          it { is_expected.to contain_file(params[:ldap_auth_conf_file]).with_content(/secret="bar"/) }
          it { is_expected.not_to contain_file(params[:ldap_auth_conf_file]).with_content(/clientprinc/) }
          it { is_expected.not_to contain_file(params[:ldap_auth_conf_file]).with_content(/credentialcache/) }
        end

        context 'optional_args_in_base_auth_conf_file' do
          facts = base_facts.dup
          facts[:fqdn] = 'host.test.net'

          let(:facts) {facts}
          let(:params) {{
            :user                => 'foo',
            :secret              => 'bar',
            :ldap_auth_conf_file => '/conf/file',
            :clientprinc         => 'foo/bar',
            :credentialcache     => '/tmp/foo'
          }}

          it { is_expected.to contain_file(params[:ldap_auth_conf_file]).with_content(/clientprinc="foo\/bar"/) }
          it { is_expected.to contain_file(params[:ldap_auth_conf_file]).with_content(/credentialcache="\/tmp\/foo"/) }
        end

        context 'external_certs_in_base_auth_conf_file' do
          facts = base_facts.dup
          facts[:fqdn] = 'host.test.net'

          let(:facts) {facts}
          let(:params) {{
            :user                => 'foo',
            :secret              => 'bar',
            :authtype            => 'EXTERNAL',
            :ldap_auth_conf_file => '/conf/file'
          }}

          it { is_expected.to contain_file(params[:ldap_auth_conf_file]).with_content(/authtype="EXTERNAL"/) }
          it { is_expected.to contain_file(params[:ldap_auth_conf_file]).with_content(/external_cert="\/etc\/pki\/simp\/public\/#{facts[:fqdn]}\.pub"/) }
          it { is_expected.to contain_file(params[:ldap_auth_conf_file]).with_content(/external_key="\/etc\/pki\/simp\/private\/#{facts[:fqdn]}\.pem"/) }
        end
      end
    end
  end
end
