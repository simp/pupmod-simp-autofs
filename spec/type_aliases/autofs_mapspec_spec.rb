require 'spec_helper'

describe 'Autofs::Mapspec' do
  context 'with valid mapspec structure' do
    it 'should allow struct with direct maps without master_options'  do
      struct = {
        'mount_point' => '/-',
        'mappings'    => {
          'key'      => '/net/data',
          'options'  => '-fstype=nfs,soft,rw',
          'location' => 'nfs.example.com:/exports/data'
        }
      }

      is_expected.to allow_value(struct)
    end

    it 'should allow struct with array of indirect mappings with master_options'  do
      struct = {
        'mount_point'    => '/apps',
        'master_options' => 'strictexpire',
        'mappings'       => [
          {
            'key'      => 'v2',
            'options'  => '-fstype=nfs,soft,nfsvers=4,ro',
            'location' => 'nfs.example.com:/exports/apps2'
          },
          {
            'key'      => 'latest',
            'options'  => '-fstype=nfs,soft,nfsvers=4,ro',
            'location' => 'nfs.example.com:/exports/apps3'
          }
         ]
      }

      is_expected.to allow_value(struct)
    end
  end

  context 'with invalid mapspec structure' do
    it 'should fail when mount_point is not a fully qualified path'  do
      struct = {
        'mount_point' => '-',
        'mappings'    => {
          'key'      => '/net/data',
          'options'  => '-fstype=nfs,soft,rw',
          'location' => 'nfs.example.com:/exports/data'
        }
      }

      is_expected.to_not allow_value(struct)
    end

    it 'should fail when direct mapping is invalid'  do
      struct = {
        'mount_point' => '/-',
        'mappings'    => {
          'key'      => 'apps',
          'location' => 'nfs.example.com:/exports/apps'
        }
      }
      is_expected.to_not allow_value(struct)
    end

    it 'should fail when indirect mapping is invalid'  do
      struct = {
        'mount_point' => '/net',
        'mappings'    => [
          {
            'key'      => 'apps',
            'options'  => '-fstype=nfs, soft, nfsvers=4, ro',
            'location' => 'nfs.example.com:/exports/apps'
          }
        ]
      }

      is_expected.to_not allow_value(struct)
    end
  end
end
