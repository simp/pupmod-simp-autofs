require 'spec_helper'

describe 'Autofs::Directmapping' do
  context 'with valid direct map structure' do
    it 'should allow struct without options'  do
      struct = {
        'key'      => '/net/apps',
        'location' => 'nfs.example.com:/exports/apps'
      }
      is_expected.to allow_value(struct)
    end

    it 'should allow struct with options'  do
      struct = {
        'key'      => '/net/data',
        'options'  => '-fstype=nfs,soft,rw',
        'location' => 'nfs.example.com:/exports/data'
      }
      is_expected.to allow_value(struct)
    end
  end

  context 'with invalid direct map structure' do
    context 'invalid key' do
      it 'should fail when key is not a fully qualified path'  do
        struct = {
          'key'      => 'apps',
          'location' => 'nfs.example.com:/exports/apps'
        }
        is_expected.to_not allow_value(struct)
      end
    end

    context 'invalid options' do
      it 'should fail when options begins with whitespace'  do
        struct = {
          'key'      => '/net/apps',
          'options'  => ' -fstype=nfs,soft,rw',
          'location' => 'nfs.example.com:/exports/apps'
        }
        is_expected.to_not allow_value(struct)
      end

      it 'should fail when options ends with whitespace'  do
        struct = {
          'key'      => '/net/apps',
          'options'  => '-fstype=nfs,soft,rw ',
          'location' => 'nfs.example.com:/exports/apps'
        }
        is_expected.to_not allow_value(struct)
      end

      it 'should fail when options has whitespace in middle'  do
        struct = {
          'key'      => '/net/apps',
          'options'  => '-fstype=nfs, soft, rw',
          'location' => 'nfs.example.com:/exports/apps'
        }
        is_expected.to_not allow_value(struct)
      end
    end

    context 'invalid location' do
      it 'should fail when location is empty'  do
        struct = {
          'key'      => '/net/apps',
          'location' => ''
        }
        is_expected.to_not allow_value(struct)
      end

      it 'should fail when location has all whitespace characters'  do
        struct = {
          'key'      => '/net/apps',
          'location' => " \t "
        }
      end
    end
  end
end
