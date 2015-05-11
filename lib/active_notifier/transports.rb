module ActiveNotifier
  module Transports
    extend ActiveSupport::Autoload

    autoload :ActionMailer
    autoload :Pushmeup

    def self.for(channel, configuration, notifier)
      transport_klass = self.constants.map do |klass_name|
        self.const_get(klass_name)
      end.detect do |klass|
        klass.channel == channel
      end || fail("No transport defined for channel '#{channel}'")

      transport_klass.new(configuration, notifier)
    end
  end
end
