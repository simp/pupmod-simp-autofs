require 'spec_helper'

describe 'autofs::mapfile' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with a direct mapping' do
        let(:title) { 'apps' }
        let(:map_file) { '/etc/autofs.maps.simp.d/apps.map' }

        context 'without mapping options' do
          let(:params) do
            {
              mappings: {
                'key'      => '/net/apps',
                'location' => '1.2.3.4:/exports/apps'
              }
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('autofs') }
          it { is_expected.to contain_autofs__mapfile(title) }
          it {
            is_expected.to contain_file(map_file).with({
                                                         owner: 'root',
             group: 'root',
             mode: '0640',
             content: <<~EOM
              # This file is managed by Puppet (simp-autofs module).  Changes will be
              # overwritten at the next puppet run.
              /net/apps    1.2.3.4:/exports/apps
            EOM
                                                       })
          }

          it { is_expected.to contain_file(map_file).that_notifies('Exec[autofs_reload]') }
        end

        context 'with mapping options' do
          let(:params) do
            {
              mappings: {
                'key'      => '/net/apps',
                'options'  => '-fstype=nfs,soft,nfsvers=4,ro',
                'location' => '1.2.3.4:/exports/apps'
              }
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_autofs__mapfile(title) }
          it {
            is_expected.to contain_file(map_file).with_content(
             <<~EOM,
              # This file is managed by Puppet (simp-autofs module).  Changes will be
              # overwritten at the next puppet run.
              /net/apps  -fstype=nfs,soft,nfsvers=4,ro  1.2.3.4:/exports/apps
            EOM
           )
          }

          it { is_expected.to contain_file(map_file).that_notifies('Exec[autofs_reload]') }
        end
      end

      context 'with a single indirect mapping' do
        let(:title) { 'home' }
        let(:map_file) { '/etc/autofs.maps.simp.d/home.map' }

        context 'without mapping options' do
          let(:params) do
            {
              mappings: [ {
                'key'      => '*',
                'location' => '1.2.3.4:/exports/home/&'
              } ]
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_autofs__mapfile(title) }
          it {
            is_expected.to contain_file(map_file).with_content(
             <<~EOM,
              # This file is managed by Puppet (simp-autofs module).  Changes will be
              # overwritten at the next puppet run.
              *    1.2.3.4:/exports/home/&
            EOM
           )
          }

          it { is_expected.not_to contain_file(map_file).that_notifies('Exec[autofs_reload]') }
        end

        context 'with mapping options' do
          let(:params) do
            {
              mappings: [ {
                'key'      => '*',
                'options'  => '-fstype=nfs,soft,nfsvers=4,ro',
                'location' => '1.2.3.4:/exports/home/&'
              } ]
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_autofs__mapfile(title) }
          it {
            is_expected.to contain_file(map_file).with_content(
             <<~EOM,
              # This file is managed by Puppet (simp-autofs module).  Changes will be
              # overwritten at the next puppet run.
              *  -fstype=nfs,soft,nfsvers=4,ro  1.2.3.4:/exports/home/&
            EOM
           )
          }

          it { is_expected.not_to contain_file(map_file).that_notifies('Exec[autofs_reload]') }
        end
      end

      context 'with a multiple indirect mappings' do
        let(:title) { 'apps' }
        let(:map_file) { '/etc/autofs.maps.simp.d/apps.map' }
        let(:params) do
          {
            mappings: [
              {
                'key'      => 'v1',
                'location' => '1.2.3.4:/exports/apps1'
              },
              {
                'key'      => 'v2',
                'options'  => '-fstype=nfs,soft,nfsvers=4,ro',
                'location' => '1.2.3.5:/exports/apps2'
              },
              {
                'key'      => 'latest',
                'location' => '1.2.3.6:/exports/apps3'
              },
            ]
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_autofs__mapfile(title) }
        it {
          is_expected.to contain_file(map_file).with_content(
           <<~EOM,
            # This file is managed by Puppet (simp-autofs module).  Changes will be
            # overwritten at the next puppet run.
            v1    1.2.3.4:/exports/apps1
            v2  -fstype=nfs,soft,nfsvers=4,ro  1.2.3.5:/exports/apps2
            latest    1.2.3.6:/exports/apps3
          EOM
         )
        }

        it { is_expected.not_to contain_file(map_file).that_notifies('Exec[autofs_reload]') }
      end

      context 'with maps_dir' do
        let(:title) { 'apps' }
        let(:params) do
          {
            mappings: {
              'key'      => '/net/apps',
              'location' => '1.2.3.4:/exports/apps'
            },
          maps_dir: '/etc/maps.d'
          }
        end

        let(:map_file) { '/etc/maps.d/apps.map' }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file(map_file) }
        it { is_expected.to contain_file(map_file).that_notifies('Exec[autofs_reload]') }
      end

      context 'with / in title' do
        let(:title) { '/net/apps' }
        let(:params) do
          {
            mappings: {
              'key'      => '/net/apps',
              'location' => '1.2.3.4:/exports/apps'
            }
          }
        end

        let(:map_file) { '/etc/autofs.maps.simp.d/net__apps.map' }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file(map_file) }
        it { is_expected.to contain_file(map_file).that_notifies('Exec[autofs_reload]') }
      end

      context 'with whitespace in title' do
        let(:title) { 'net apps' }
        let(:params) do
          {
            mappings: {
              'key'      => '/net/apps',
              'location' => '1.2.3.4:/exports/apps'
            }
          }
        end

        let(:map_file) { '/etc/autofs.maps.simp.d/net__apps.map' }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file(map_file) }
        it { is_expected.to contain_file(map_file).that_notifies('Exec[autofs_reload]') }
      end
    end
  end
end
