module ActiveNotifier
  class Base
    attr_accessor :recipient, :channels

    cattr_accessor :configurations
    self.configurations = {}

    def initialize(attributes={})
      attributes.each do |(key, value)|
        self.public_send("#{key}=", value)
      end
    end

    delegate :deliver_now, to: :deliverable

    def deliver_now
      delivered = false

      until channels.empty? || delivered
        channel = channels.shift
        begin
          deliverable(channel).deliver_now
          delivered = true
        rescue ActiveNotifier::DeliveryImpossible => e
          delivered = false
          msg = "Unable to deliver to channel #{channel}"
          ActiveNotifier.logger && ActiveNotifier.logger.warn(msg)
        end
      end
    end

    class << self
      def deliver_now(attributes)
        new(attributes).deliver_now
      end

      def deliver_through(channel, &blk)
        config = Configuration.new.tap(&blk)
        configurations[channel] = config
      end
    end

    private

    def deliverable(channel)
      configuration = configurations[channel]
      transport = ActiveNotifier::Transports.for(channel, configuration, self)
      transport.deliverable(self)
    end

    class Configuration
      def initialize
        @data = {
          from: nil,
          email_attribute: nil,
          subject: nil,
          superclass: ActionMailer::Base
        }
      end

      def method_missing(*args, &blk)
        attribute, value = args
        if value.present?
          @data[attribute] = value
        elsif block_given?
          @data[attribute] = blk
        else
          @data.fetch attribute do
            super
          end
        end
      end

      def respond_to?(*args, &blk)
        attribute, value = args
        if value.present?
          true
        elsif block_given?
          true
        else
          @data.fetch attribute do
            super
          end
        end
      end
    end
  end
end
