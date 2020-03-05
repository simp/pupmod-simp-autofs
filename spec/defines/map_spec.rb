require 'spec_helper'

describe 'autofs::map' do
 on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with a direct mapping' do
        let(:title) { 'apps' }
        let(:map_file) { '/etc/autofs.maps.simp.d/apps.map'}

        context 'without master_options' do
          let(:params) {{
            :mount_point => '/-',
            :mappings    => {
              'key'      => '/net/apps',
              'location' => '1.2.3.4:/exports/apps'
            }
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('autofs') }
          it { is_expected.to contain_autofs__masterfile(title).with( {
            :mount_point => params[:mount_point],
            :map         => map_file
          } ) }

          it { is_expected.to contain_autofs__mapfile(title).with( {
            :mappings => params[:mappings],
            :maps_dir => '/etc/autofs.maps.simp.d'
          } ) }
        end

        context 'with master_options' do
          let(:params) {{
            :mount_point    => '/-',
            :master_options => 'strictexpire --strict',
            :mappings       => {
              'key'      => '/net/apps',
              'options'  => '-fstype=nfs,soft,nfsvers=4,ro',
              'location' => '1.2.3.4:/exports/apps'
            }
          }}

          it { is_expected.to contain_autofs__masterfile(title).with( {
            :mount_point => params[:mount_point],
            :map         => map_file,
            :options     => params[:master_options]
          } ) }

          it { is_expected.to contain_autofs__mapfile(title).with( {
            :mappings => params[:mappings],
            :maps_dir => '/etc/autofs.maps.simp.d'
          } ) }
        end
      end

      context 'with a single indirect mapping' do
        let(:title) { 'home' }
        let(:map_file) { '/etc/autofs.maps.simp.d/home.map'}

        context 'without master_options' do
          let(:params) {{
            :mount_point => '/home',
            :mappings    => [ {
              'key'      => '*',
              'location' => '1.2.3.4:/exports/home/&'
            } ]
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_autofs__masterfile(title).with( {
            :mount_point => params[:mount_point],
            :map         => map_file
          } ) }

          it { is_expected.to contain_autofs__mapfile(title).with( {
            :mappings => params[:mappings],
            :maps_dir => '/etc/autofs.maps.simp.d'
          } ) }
        end

        context 'with master_options' do
          let(:params) {{
            :mount_point    => '/home',
            :master_options => 'strictexpire --strict',
            :mappings       => [ {
              'key'      => '*',
              'options'  => '-fstype=nfs,soft,nfsvers=4,ro',
              'location' => '1.2.3.4:/exports/home/&'
            } ]
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_autofs__masterfile(title).with( {
            :mount_point => params[:mount_point],
            :map         => map_file,
            :options     => params[:master_options]
          } ) }

          it { is_expected.to contain_autofs__mapfile(title).with( {
            :mappings => params[:mappings],
            :maps_dir => '/etc/autofs.maps.simp.d'
          } ) }
        end
      end

      context 'with a multiple indirect mappings' do
        let(:title) { 'apps' }
        let(:map_file) { '/etc/autofs.maps.simp.d/apps.map'}
        let(:params) {{
          :mount_point    => '/apps',
          :mappings => [
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
        }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_autofs__masterfile(title).with( {
          :mount_point => params[:mount_point],
          :map         => map_file
        } ) }

        it { is_expected.to contain_autofs__mapfile(title).with( {
          :mappings => params[:mappings],
          :maps_dir => '/etc/autofs.maps.simp.d'
        } ) }
      end

      context 'with / in title' do
        let(:title) { 'net/apps' }
        let(:params) {{
          :mount_point => '/-',
          :mappings    => {
            'key'      => '/net/apps',
            'location' => '1.2.3.4:/exports/apps'
          }
        }}

        let(:safe_name) { 'net__apps' }
        let(:map_file) { "/etc/autofs.maps.simp.d/#{safe_name}.map" }

        it { is_expected.to compile.with_all_deps }
        it 'should replace / characters in contained defines' do
          is_expected.to contain_autofs__masterfile(safe_name).with_map(
            map_file)

          is_expected.to contain_autofs__mapfile(safe_name)
        end
      end

      context 'with whitespace in title' do
        let(:title) { 'net apps' }
        let(:params) {{
          :mount_point => '/-',
          :mappings    => {
            'key'      => '/net/apps',
            'location' => '1.2.3.4:/exports/apps'
          }
        }}

        let(:safe_name) { 'net__apps' }
        let(:map_file) { "/etc/autofs.maps.simp.d/#{safe_name}.map" }

        it { is_expected.to compile.with_all_deps }
        it 'should replace / characters in contained defines' do
          is_expected.to contain_autofs__masterfile(safe_name).with_map(
            map_file)

          is_expected.to contain_autofs__mapfile(safe_name)
        end
      end
    end
  end
end
