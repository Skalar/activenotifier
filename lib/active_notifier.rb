require 'active_support'

module ActiveNotifier
  extend ActiveSupport::Autoload

  mattr_accessor :logger

  autoload :Base
  autoload :Transports
  autoload :DeliveryImpossible
end
