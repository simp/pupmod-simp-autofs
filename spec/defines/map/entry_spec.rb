require 'spec_helper'

describe 'autofs::map::entry' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'wildcard-stuff' }
      let(:params) {{
        :target => 'foo',
        :location => '1.2.3.4:/foo'
      }}

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_concat("/etc/autofs.maps.simp.d/#{params[:target]}.map").that_notifies('Exec[autofs_reload]') }
      it { is_expected.to contain_concat__fragment("autofs_#{params[:target]}_#{title}").with_content("*\t\t#{params[:location]}") }
    end
  end
end
