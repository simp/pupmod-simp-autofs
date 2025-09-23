require 'spec_helper'

describe 'autofs' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to create_class('autofs') }
      it { is_expected.to contain_class('autofs::install') }
      it { is_expected.to contain_class('autofs::config') }
      it { is_expected.to contain_class('autofs::service') }

      # autofs::install class is trivial, so test it here
      it { is_expected.to contain_package('samba-client').with_ensure('installed') }
      it { is_expected.to contain_package('autofs').with_ensure('installed') }

      # autofs::service class is also trivial, so test it here
      it {
        is_expected.to contain_service('autofs').with({
                                                        ensure: 'running',
       enable: true,
       hasstatus: true,
       hasrestart: true,
                                                      })
      }

      it {
        is_expected.to contain_exec('autofs_reload').with({
                                                            command: '/usr/bin/systemctl reload autofs',
        refreshonly: true,
                                                          })
      }
    end
  end
end
