require 'active_job'

module ActiveNotifier
  module Transports
    class Pushmeup
      attr_accessor :configuration
      cattr_accessor :channel

      self.channel = :push

      def initialize(configuration, notifier)
        self.configuration = configuration
      end

      def deliverable(notifier)
        token_attribute = configuration.token_attribute
        token = notifier.recipient.public_send(token_attribute)

        network_attribute = configuration.network_attribute
        network = notifier.recipient.public_send(network_attribute)

        payload = configuration.serializer.new(notifier).as_json(root: false)

        Deliverable.new(token, payload, network)
      end

      def self.deliver(token, payload, network)
        case network
        when 'apns'
          APNS.send_notification(token, payload)
        when 'gcm'
          GCM.send_notification(token, payload)
        else
          fail "Unrecognized network"
        end
      end

      private

      class PushNotificationJob < ActiveJob::Base
        queue_as :push_notifications

        def perform(token, payload, network)
          ActiveNotifier::Transports::Pushmeup.deliver(@token, @payload, @network)
        end
      end

      class Deliverable
        attr_accessor :payload, :token, :network

        def initialize(token, payload, network)
          @payload = payload
          @token   = token
          @network = network
        end

        def deliver_now
          ActiveNotifier::Transports::Pushmeup.deliver(token, payload, network)
        end

        def deliver_later
          PushNotificationJob.perform_later(token, payload, network)
        end
      end
    end
  end
end
