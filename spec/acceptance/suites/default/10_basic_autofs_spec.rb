require 'spec_helper_acceptance'

test_name 'basic autofs'

describe 'basic autofs' do
  # only going to use one NFS server
  server = hosts_with_role(hosts, 'nfs_server').first
  clients = hosts_with_role(hosts, 'nfs_client')

  let(:server_fqdn) { fact_on(server, 'fqdn') }
  let(:client_hieradata) do
    {
      # Set us up for a basic autofs (no LDAP)
      'simp_options::ldap' => false,
   'simp_options::pki'  => false,
   # set up automounts
   'autofs::maps'       => {
     # indirect mount with multiple explicit keys
     'apps' => {
       'mount_point' => '/net/apps',
       'mappings'    => [
         {
           'key'      => 'v1',
           'options'  => '-fstype=nfs,soft,nfsvers=4,ro',
           'location' => "#{server_fqdn}:/exports/apps1"
         },
         {
           'key'      => 'v2',
           'options'  => '-fstype=nfs,soft,nfsvers=4,ro',
           'location' => "#{server_fqdn}:/exports/apps2"
         },
         {
           'key'      => 'latest',
           'options'  => '-fstype=nfs,soft,nfsvers=4,ro',
           'location' => "#{server_fqdn}:/exports/apps3"
         },
       ]
     },
     # direct mount
     'data' => {
       'mount_point' => '/-',
       'mappings'    => {
         'key'      => '/net/data',
         'options'  => '-fstype=nfs,soft,nfsvers=4,ro',
         'location' => "#{server_fqdn}:/exports/data"
       }
     },
     # indirect mount with wildcard key and key substitution
     # Don't use /home or vagrant's home directory will be
     # masked and you won't be able to login!
     'home.new' => {
       'mount_point'    => '/home.new',
       'master_options' => 'strictexpire --strict',
       'mappings'       => [ {
         'key'      => '*',
         'options'  => '-fstype=nfs,soft,nfsvers=4,rw',
         'location' => "#{server_fqdn}:/exports/home/&"
       } ]
     }
   }
    }
  end

  let(:client_manifest) { 'include autofs' }
  let(:file_content_base) { 'This is a test file from' }
  let(:mounted_files) do
    [
      '/net/apps/v1/test_file',
      '/net/apps/v2/test_file',
      '/net/apps/latest/test_file',
      '/net/data/test_file',
      '/home.new/user1/test_file',
      '/home.new/user2/test_file',
    ]
  end

  context 'autofs clients' do
    clients.each do |client|
      context "as autofs client #{client} using NFS server #{server}" do
        it "applies client manifest to mount dirs from #{server}" do
          set_hieradata_on(client, client_hieradata)
          apply_manifest_on(client, client_manifest, catch_failures: true)
        end

        it 'is idempotent' do
          apply_manifest_on(client, client_manifest, catch_changes: true)
        end

        it 'automounts NFS shares' do
          mounted_files.each do |file|
            auto_dir = File.dirname(file)
            filename = File.basename(file)
            on(client, %(cd #{auto_dir}; grep '#{file_content_base}' #{filename}))
          end
        end
      end
    end
  end
end
