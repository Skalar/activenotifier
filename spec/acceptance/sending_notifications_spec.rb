require 'spec_helper'
require 'action_mailer'
require 'active_model_serializers'
require 'pushmeup'

ActionMailer::Base.delivery_method = :test
view_path = File.expand_path('../../app/views', __FILE__)
ActionMailer::Base.prepend_view_path(view_path)

class LikeNotificationSerializer < ActiveModel::Serializer
  attributes :alert, :badge, :sound, :other

  def alert
    'You just received a like'
  end

  def badge
    1
  end

  def sound
    'default'
  end

  def other
    {
      sent: 'with activenotifier'
    }
  end
end

describe "sending notifications" do
  class LikeNotifier < ActiveNotifier::Base
    attr_accessor :like

    deliver_through :email do |config|
      config.email_attribute :email_address # defaults to :email
      config.subject "You just received a like"
      config.from "noreply@example.com"
    end

    deliver_through :push do |config|
      config.network_attribute :device_network
      config.token_attribute :device_token
      config.serializer LikeNotificationSerializer
    end
  end

  class MultipleLikeNotifier < ActiveNotifier::Base
    attr_accessor :like

    deliver_through :push do |config|
      config.device_list_attribute :devices
      config.network_attribute :network
      config.token_attribute :token
      config.serializer LikeNotificationSerializer
    end
  end

  before(:each) do
    ActionMailer::Base.deliveries.clear
  end

  let(:expected_push_payload) do
    {
      :alert => 'You just received a like',
      :badge => 1,
      :sound => 'default',
      :other => {
        :sent => 'with activenotifier'
      }
    }
  end

  it "sends an email" do
    expect {
      LikeNotifier.deliver_now({
        recipient: double(email_address: 'john.doe@example.com'),
        like: double('Like'),
        channels: [:email]
      })
    }.to change {
      ActionMailer::Base.deliveries.size
    }.from(0).to(1)
    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eq ['john.doe@example.com']
    expect(mail.from).to eq ['noreply@example.com']
    expect(mail.subject).to eq 'You just received a like'
    expect(mail.body.encoded.strip).to eq 'You just received a like!'
  end

  it "sends a push notification (apns)" do
    expect(APNS).to receive(:send_notification).with('abcdefg', expected_push_payload)
    LikeNotifier.deliver_now({
      recipient: double(device_network: 'apns', device_token: 'abcdefg'),
      like: double('Like'),
      channels: [:push]
    })
  end

  it "sends a push notification (gcm)" do
    expect(GCM).to receive(:send_notification).with('12345678', expected_push_payload)
    LikeNotifier.deliver_now({
      recipient: double(device_network: 'gcm', device_token: '12345678'),
      like: double('Like'),
      channels: [:push]
    })
  end

  describe "sending push to multiple devices" do
    let(:recipient) do
      double({
        devices: [
          double(network: 'apns', token: 'abcdefg'),
          double(network: 'gcm', token: '12345678')
        ]
      })
    end
    it "sends a push notification (apns AND gcm)" do
      expect(GCM).to receive(:send_notification).with('12345678', expected_push_payload)
      expect(APNS).to receive(:send_notification).with('abcdefg', expected_push_payload)
      MultipleLikeNotifier.deliver_now({
        recipient: recipient,
        like: double('Like'),
        channels: [:push]
      })
    end
  end

  describe "fallback channels", :focus do
    it "sends an email of no token is present on the recipient" do
      expect {
        LikeNotifier.deliver_now({
          recipient: double({
            email_address: 'john.doe@example.com',
            device_network: nil,
            device_token: nil
          }),
          like: double('Like'),
          channels: [:push, :email]
        })
      }.to change {
        ActionMailer::Base.deliveries.size
      }.from(0).to(1)
      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to eq ['john.doe@example.com']
      expect(mail.from).to eq ['noreply@example.com']
      expect(mail.subject).to eq 'You just received a like'
      expect(mail.body.encoded.strip).to eq 'You just received a like!'
    end

    it "logs failures" do
      logger = double('Logger')
      expect(logger).to receive(:warn)
      ActiveNotifier.logger = logger
      LikeNotifier.deliver_now({
        recipient: double({
          email_address: 'john.doe@example.com',
          device_network: nil,
          device_token: nil
        }),
        like: double('Like'),
        channels: [:push, :email]
      })
      ActiveNotifier.logger = nil
    end
  end
end
