# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'notification channel initializers', feature_category: :integrations do
  let(:registry) { Gitlab::Notifications::Channels }
  let(:expected_channels) do
    [[:wecom, Gitlab::Wecom::NotificationChannel], [:feishu, Gitlab::Feishu::NotificationChannel]]
  end

  around do |example|
    registrations = registry.instance_variable_get(:@registrations)
    example.run
  ensure
    registry.instance_variable_set(:@registrations, registrations)
  end

  def prepare_callbacks
    callbacks = []
    allow(Rails.application.config).to receive(:to_prepare) { |&block| callbacks << block }
    %w[notification_channels feishu_notification_channel].each do |name|
      load Rails.root.join("jh/config/initializers/#{name}.rb")
    end
    callbacks
  end

  def registered_channels
    registry.to_enum(:each).to_a
  end

  it 'registers each channel once at boot and after every reload' do
    callbacks = prepare_callbacks

    # Boot, then two reloads: each reload replaces the registry and runs the prepare callbacks again.
    3.times do
      registry.instance_variable_set(:@registrations, nil)
      callbacks.each(&:call)

      expect(registered_channels).to match_array(expected_channels)
    end
  end

  it 'does not add a channel twice when the prepare callbacks run again without a reload' do
    callbacks = prepare_callbacks
    registry.instance_variable_set(:@registrations, nil)
    2.times { callbacks.each(&:call) }

    expect(registered_channels).to match_array(expected_channels)
  end
end
