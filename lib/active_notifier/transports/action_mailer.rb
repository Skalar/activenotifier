module ActiveNotifier
  module Transports
    class ActionMailer
      attr_accessor :configuration
      cattr_accessor :channel

      self.channel = :email

      def initialize(configuration, notifier)
        self.configuration = configuration
      end

      def deliverable(notifier)
        email_attribute = configuration.email_attribute
        to = notifier.recipient.public_send(email_attribute)
        if to.blank?
          raise ActiveNotifier::DeliveryImpossible.new("Recipient email not present.")
        end

        mailer_class(notifier).notification({
          to: to
        })
      end

      private
      def mailer_class(notifier)
        Class.new(configuration.superclass) do
          cattr_accessor :_template_name, :_from, :_subject

          def notification(options)
            options.merge!({
              template_path: 'notifiers',
              template_name: _template_name,
              from: _from,
              subject: _subject
            })
            mail(options)
          end
        end.tap do |klass|
          klass._template_name = notifier.class.name.underscore.gsub(/_notifier$/, '')
          klass._from = configuration.from
          klass._subject = configuration.subject
        end
      end
    end
  end
end
