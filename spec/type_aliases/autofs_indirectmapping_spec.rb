require 'spec_helper'

describe 'Autofs::Indirectmapping' do
  context 'with valid indirect map structure' do
    it 'should allow struct without options'  do
      struct = {
        'key'      => 'apps',
        'location' => 'nfs.example.com:/exports/apps'
      }
      is_expected.to allow_value(struct)
    end

    it 'should allow struct with options'  do
      struct = {
        'key'      => '*',
        'options'  => '-fstype=nfs,soft,rw',
        'location' => 'nfs.example.com:/exports/home/&'
      }
      is_expected.to allow_value(struct)
    end
  end

  context 'with invalid indirect map structure' do
    context 'invalid key' do
      it 'should fail when key begins with whitespace'  do
        struct = {
          'key'      => ' apps',
          'location' => 'nfs.example.com:/exports/apps'
        }
        is_expected.to_not allow_value(struct)
      end

      it 'should fail when key ends with whitespace'  do
        struct = {
          'key'      => 'apps ',
          'location' => 'nfs.example.com:/exports/apps'
        }
        is_expected.to_not allow_value(struct)
      end

      it 'should fail when key has whitespace in middle'  do
        struct = {
          'key'      => 'ap ps',
          'location' => 'nfs.example.com:/exports/apps'
        }
        is_expected.to_not allow_value(struct)
      end

      it 'should fail when key begins with /'  do
        struct = {
          'key'      => '/apps',
          'location' => 'nfs.example.com:/exports/apps'
        }
        is_expected.to_not allow_value(struct)
      end

      it 'should fail when key ends with /'  do
        struct = {
          'key'      => 'apps/',
          'location' => 'nfs.example.com:/exports/apps'
        }
        is_expected.to_not allow_value(struct)
      end

      it 'should fail when key has / in middle'  do
        struct = {
          'key'      => 'apps/local',
          'location' => 'nfs.example.com:/exports/apps'
        }
        is_expected.to_not allow_value(struct)
      end
    end

    context 'invalid options' do
      it 'should fail when options begins with whitespace'  do
        struct = {
          'key'      => 'apps',
          'options'  => ' -fstype=nfs,soft,rw',
          'location' => 'nfs.example.com:/exports/apps'
        }
        is_expected.to_not allow_value(struct)
      end

      it 'should fail when options ends with whitespace'  do
        struct = {
          'key'      => 'apps',
          'options'  => '-fstype=nfs,soft,rw ',
          'location' => 'nfs.example.com:/exports/apps'
        }
        is_expected.to_not allow_value(struct)
      end

      it 'should fail when options has whitespace in middle'  do
        struct = {
          'key'      => 'apps',
          'options'  => '-fstype=nfs, soft, rw',
          'location' => 'nfs.example.com:/exports/apps'
        }
        is_expected.to_not allow_value(struct)
      end
    end

    context 'invalid location' do
      it 'should fail when location is empty'  do
        struct = {
          'key'      => 'apps',
          'location' => ''
        }
        is_expected.to_not allow_value(struct)
      end

      it 'should fail when location has all whitespace characters'  do
        struct = {
          'key'      => 'apps',
          'location' => " \t "
        }
      end
    end
  end
end
