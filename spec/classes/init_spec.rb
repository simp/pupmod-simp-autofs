require 'spec_helper'

describe 'autofs' do
  base_facts = {
    :interfaces => 'eth0, lo0',
    :operatingsystem => 'RedHat',
    :spec_title => description
  }

  let(:facts) {base_facts}

  it { should create_class('autofs') }
  it { should contain_class('nfs') }

  context 'base' do
    it { should contain_class('autofs::ldap_auth') }
    it { should contain_package('nfs-utils').that_comes_before('Package[autofs]') }
  end

  context 'no_nfs' do
    facts = base_facts.dup
    facts[:spec_title] = File.join(superclass.description,description).gsub(':','_')
    let(:facts) {facts}

    it { should_not contain_package('nfs-utils').that_comes_before('Package[autofs]') }
  end

  context 'no_ldap_auth_conf_file' do
    facts = base_facts.dup
    facts[:spec_title] = File.join(superclass.description,description).gsub(':','_')
    let(:facts) {facts}

    it { should_not contain_class('autofs::ldap_auth') }
  end
end
