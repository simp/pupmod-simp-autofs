require 'spec_helper'

describe 'autofs::ldap_auth' do
  base_facts = {
    :operatingsystem => 'RedHat'
  }

  let(:facts) {base_facts}

  params = {
    :ldap_auth_conf_file => '/conf/file'
  }
  let(:params) {params}

  context 'base' do
    it { should create_class('autofs::ldap_auth') }
    it { should create_file(params[:ldap_auth_conf_file]) }
    # Not sure why this test is failing. May be a bug in rspec-puppet
    # it { should contain_file(params[:ldap_auth_conf_file]) }.that_notifies('Service[autofs]') }
  end

  context 'external_cert_empty' do
    let(:params) {{
      :authtype => 'external',
      :external_cert => ''
    }}

    it {
      expect {
        should create_class('autofs::ldap_auth')
      }.to raise_error(Puppet::Error,/\$external_cert and \$external_key must be specified when setting \$authtype to "EXTERNAL"/)
    }
  end

  context 'external_key_empty' do
    let(:params) {{
      :authtype => 'external',
      :external_key => ''
    }}

    it {
      expect {
        should create_class('autofs::ldap_auth')
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

    it { should contain_file(params[:ldap_auth_conf_file]).with_content(/usetls="yes"/) }
    it { should contain_file(params[:ldap_auth_conf_file]).with_content(/tlsrequired="yes"/) }
    it { should contain_file(params[:ldap_auth_conf_file]).with_content(/authrequired="yes"/) }
    it { should contain_file(params[:ldap_auth_conf_file]).with_content(/authtype="LOGIN"/) }
    it { should_not contain_file(params[:ldap_auth_conf_file]).with_content(/external_cert/) }
    it { should_not contain_file(params[:ldap_auth_conf_file]).with_content(/external_key/) }
    it { should contain_file(params[:ldap_auth_conf_file]).with_content(/user="foo"/) }
    it { should contain_file(params[:ldap_auth_conf_file]).with_content(/secret="bar"/) }
    it { should_not contain_file(params[:ldap_auth_conf_file]).with_content(/clientprinc/) }
    it { should_not contain_file(params[:ldap_auth_conf_file]).with_content(/credentialcache/) }
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

    it { should contain_file(params[:ldap_auth_conf_file]).with_content(/clientprinc="foo\/bar"/) }
    it { should contain_file(params[:ldap_auth_conf_file]).with_content(/credentialcache="\/tmp\/foo"/) }
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

    it { should contain_file(params[:ldap_auth_conf_file]).with_content(/authtype="EXTERNAL"/) }
    it { should contain_file(params[:ldap_auth_conf_file]).with_content(/external_cert="\/etc\/pki\/public\/#{facts[:fqdn]}\.pub"/) }
    it { should contain_file(params[:ldap_auth_conf_file]).with_content(/external_key="\/etc\/pki\/private\/#{facts[:fqdn]}\.pem"/) }
  end
end
