require 'spec_helper_acceptance'

test_name 'NFS setup'

describe 'NFS setup' do

  # only going to use one NFS server
  server = hosts_with_role( hosts, 'nfs_server' ).first
  clients = hosts_with_role( hosts, 'nfs_client' )

  context 'disable firewalld' do
    it 'should stop firewalld service' do
      # OEL test boxes have firewalld running by default and we don't
      # need to test with the firewall here.
      on(hosts, 'puppet resource service firewalld ensure=stopped')
    end
  end

  context 'NFS client set up' do
    let(:client_hieradata) {{
      # Set us up for a barebone NFS (no security features)
      'simp_options::firewall'    => false,
      'simp_options::kerberos'    => false,
      'simp_options::stunnel'     => false,
      'simp_options::tcpwrappers' => false
    }}

    let(:client_manifest) { 'include nfs' }

    clients.each do |client|
      it 'should apply client manifest to install and start NFS client services' do
        set_hieradata_on(client, client_hieradata)
        apply_manifest_on(client, client_manifest, :catch_failures => true)
      end

      it 'should be idempotent' do
        apply_manifest_on(client, client_manifest, :catch_changes => true)
      end
    end
  end

  context "NFS server set up on #{server}" do
    let(:server_hieradata) {{
      # Set us up for a barebone NFS (no security features)
      'simp_options::firewall'    => false,
      'simp_options::kerberos'    => false,
      'simp_options::stunnel'     => false,
      'simp_options::tcpwrappers' => false,
      'nfs::is_server'            => true
    }}

    let(:export_root_path) { '/exports' }
    let(:export_mapping)  { {
      :data            => {
        :export_dir     => "#{export_root_path}/data",
        :exported_files => [ "#{export_root_path}/data/test_file" ]
      },
      :apps1 => {
        :export_dir     => "#{export_root_path}/apps1",
        :exported_files => [ "#{export_root_path}/apps1/test_file" ]
      },
      :apps2 => {
        :export_dir     => "#{export_root_path}/apps2",
        :exported_files => [ "#{export_root_path}/apps2/test_file" ]
      },
      :apps3 => {
        :export_dir     => "#{export_root_path}/apps3",
        :exported_files => [ "#{export_root_path}/apps3/test_file" ]
      },
      :home => {
        :export_dir     => "#{export_root_path}/home",
        :exported_files => [
          "#{export_root_path}/home/user1/test_file",
          "#{export_root_path}/home/user2/test_file"
        ]
      }
    } }

    let(:export_dirs) { export_mapping.map { |name,info| info[:export_dir] }.flatten }
    let(:exported_files) { export_mapping.map { |name,info| info[:exported_files] }.flatten }
    let(:file_content_base) { 'This is a test file from' }
    let(:server_manifest) {
      <<~EOM
        file { '#{export_root_path}':
          ensure  => 'directory',
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          seltype => 'default_t'
        }

        $export_dirs = [
          '#{export_dirs.join("',\n  '")}'
        ]

        $export_dirs.each |String $_export_dir| {
          file { $_export_dir:
            ensure => 'directory',
            owner  => 'root',
            group  => 'root',
            mode   => '0644'
          }

          nfs::server::export { $_export_dir:
            clients     => ['*'],
            export_path => $_export_dir
          }

          File["${_export_dir}"] -> Nfs::Server::Export["${_export_dir}"]
        }

        $files = [
          '#{exported_files.join("',\n  '")}'
        ]

        $dir_attr = {
          ensure => 'directory',
          owner  => 'root',
          group  => 'root',
          mode   => '0644'
        }

        $files.each |String $_file| {
          $_path = dirname($_file)
          ensure_resource('file', $_path, $dir_attr)

          file { $_file:
            ensure  => 'file',
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            content => "#{file_content_base} ${_path}",
          }
        }
      EOM
    }

    it 'should apply server manifest to export' do
      set_hieradata_on(server, server_hieradata)
      apply_manifest_on(server, server_manifest, :catch_failures => true)
    end

    it 'should be idempotent' do
      apply_manifest_on(server, server_manifest, :catch_changes => true)
    end

    it 'should export shared dirs' do
      on(server, 'exportfs -v')
      export_dirs.each do |dir|
        on(server, "exportfs -v | grep -w #{dir}")
      end

      on(server, "find #{export_root_path} -type f | sort")
    end
  end
end
