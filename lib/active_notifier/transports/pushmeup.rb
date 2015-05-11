require 'active_job'
require 'delegate'

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
        if configuration[:device_list_attribute]
          devices = notifier.recipient.public_send(configuration[:device_list_attribute])
        else
          devices = Array(notifier.recipient)
        end

        deliverables = devices.map do |device|
          token_attribute = configuration.token_attribute
          token = device.public_send(token_attribute)
          if token.blank?
            raise ActiveNotifier::DeliveryImpossible.new("Recipient mobile token not present.")
          end

          network_attribute = configuration.network_attribute
          network = device.public_send(network_attribute)
          if token.blank?
            raise ActiveNotifier::DeliveryImpossible.new("Recipient network token not present.")
          end

          payload = configuration.serializer.new(notifier).as_json(root: false)

          Deliverable.new(token, payload, network)
        end
        MultipleDeliverables.new(deliverables)
      end

      def self.deliver(tokens, payload, network)
        case network
        when 'apns'
          APNS.send_notification(tokens, payload)
        when 'gcm'
          GCM.send_notification(tokens, payload)
        else
          fail "Unrecognized network"
        end
      end

      private

      class PushNotificationJob < ActiveJob::Base
        queue_as :push_notifications

        def perform(tokens, payload, network)
          ActiveNotifier::Transports::Pushmeup.deliver(token, payload, network)
        end
      end

      class Deliverable
        attr_accessor :payload, :tokens, :network

        def initialize(tokens, payload, network)
          @payload = payload
          @tokens  = tokens
          @network = network
        end

        def deliver_now
          ActiveNotifier::Transports::Pushmeup.deliver(tokens, payload, network)
        end

        def deliver_later
          PushNotificationJob.perform_later(tokens, payload, network)
        end
      end

      class MultipleDeliverables < SimpleDelegator
        def deliver_now
          each(&:deliver_now)
        end

        def deliver_later
          each(&:deliver_now)
        end
      end
    end
  end
end
