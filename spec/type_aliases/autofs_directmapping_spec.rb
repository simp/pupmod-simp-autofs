require 'spec_helper'

describe 'Autofs::Directmapping' do
  context 'with valid direct map structure' do
    it 'allows struct without options' do
      struct = {
        'key'      => '/net/apps',
        'location' => 'nfs.example.com:/exports/apps'
      }
      is_expected.to allow_value(struct)
    end

    it 'allows struct with options' do
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
      it 'fails when key is not a fully qualified path' do
        struct = {
          'key'      => 'apps',
          'location' => 'nfs.example.com:/exports/apps'
        }
        is_expected.not_to allow_value(struct)
      end
    end

    context 'invalid options' do
      it 'fails when options begins with whitespace' do
        struct = {
          'key'      => '/net/apps',
          'options'  => ' -fstype=nfs,soft,rw',
          'location' => 'nfs.example.com:/exports/apps'
        }
        is_expected.not_to allow_value(struct)
      end

      it 'fails when options ends with whitespace' do
        struct = {
          'key'      => '/net/apps',
          'options'  => '-fstype=nfs,soft,rw ',
          'location' => 'nfs.example.com:/exports/apps'
        }
        is_expected.not_to allow_value(struct)
      end

      it 'fails when options has whitespace in middle' do
        struct = {
          'key'      => '/net/apps',
          'options'  => '-fstype=nfs, soft, rw',
          'location' => 'nfs.example.com:/exports/apps'
        }
        is_expected.not_to allow_value(struct)
      end
    end

    context 'invalid location' do
      it 'fails when location is empty' do
        struct = {
          'key'      => '/net/apps',
          'location' => ''
        }
        is_expected.not_to allow_value(struct)
      end

      it 'fails when location has all whitespace characters' do
        {
          'key'      => '/net/apps',
          'location' => " \t "
        }
      end
    end
  end
end
