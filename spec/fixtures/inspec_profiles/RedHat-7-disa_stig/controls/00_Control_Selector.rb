skips = {}
overrides = []
subsystems = [ 'autofs' ]


require_controls 'disa_stig-el7-baseline' do
  skips.each_pair do |ctrl, reason|
    control ctrl do
      describe "Skip #{ctrl}" do
        skip "Reason: #{skips[ctrl]}" do
        end
      end
    end
  end

  @conf['profile'].info[:controls].each do |ctrl|
    next if (overrides + skips.keys).include?(ctrl[:id])

    tags = ctrl[:tags]
    if tags && tags[:subsystems]
      subsystems.each do |subsystem|
        if tags[:subsystems].include?(subsystem)
          control ctrl[:id]
        end
      end
    end
  end

  ## Overrides ##

  # Since we're managing autofs, we actually want to make sure that it's *running*
  control 'V-71985' do
    overrides << self.to_s

    describe systemd_service('autofs.service') do
      it { should be_running }
      it { should be_enabled }
      it { should be_installed }
    end
  end
end
