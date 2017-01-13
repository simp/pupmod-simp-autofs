require 'spec_helper'

describe 'autofs::ldap_auth' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        base_facts = facts
        let(:facts) {base_facts}

        params = { :ldap_auth_conf_file => '/conf/file' }
        let(:params) {params}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('autofs::ldap_auth') }
        it { is_expected.to create_file(params[:ldap_auth_conf_file]) }

        context 'base_auth_conf_file' do
          let(:facts) {facts}
          let(:params) {{
            :user                => 'foo',
            :secret              => 'bar',
            :authtype            => 'LOGIN',
            :ldap_auth_conf_file => '/conf/file'
          }}

          it { is_expected.to compile.with_all_deps }
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
          let(:params) {{
            :user                => 'foo',
            :secret              => 'bar',
            :ldap_auth_conf_file => '/conf/file',
            :clientprinc         => 'foo/bar',
            :credentialcache     => '/tmp/foo'
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file(params[:ldap_auth_conf_file]).with_content(/clientprinc="foo\/bar"/) }
          it { is_expected.to contain_file(params[:ldap_auth_conf_file]).with_content(/credentialcache="\/tmp\/foo"/) }
        end

        context 'external_certs_in_base_auth_conf_file' do
          let(:pre_condition){
            'class { "autofs": pki => "simp" }'
          }
          let(:params) {{
            :user                => 'foo',
            :secret              => 'bar',
            :authtype            => 'EXTERNAL',
            :ldap_auth_conf_file => '/conf/file'
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file(params[:ldap_auth_conf_file]).with_content(/authtype="EXTERNAL"/) }
          it { is_expected.to contain_file(params[:ldap_auth_conf_file]).with_content(%r{external_cert="/etc/pki/simp_apps/autofs/x509/public/#{facts[:fqdn]}\.pub"}) }
          it { is_expected.to contain_file(params[:ldap_auth_conf_file]).with_content(%r{external_key="/etc/pki/simp_apps/autofs/x509/private/#{facts[:fqdn]}\.pem"}) }
          it { is_expected.to create_pki__copy('autofs')}
          it { is_expected.to create_file('/etc/pki/simp_apps/autofs/x509')}
        end
      end
    end
  end
end
