# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Notifications::Channels, feature_category: :integrations do
  around do |example|
    registry = described_class.instance_variable_get(:@registrations).dup
    described_class.instance_variable_set(:@registrations, {})
    example.run
  ensure
    described_class.instance_variable_set(:@registrations, registry)
  end

  it 'resolves registered adapters lazily and checks availability at call time' do
    called = false
    adapter = class_double(Gitlab::Wecom::NotificationChannel, available?: true)
    described_class.register(:test_channel) do
      called = true
      adapter
    end

    expect(called).to be(false)
    expect { |block| described_class.each(&block) }.to yield_control.at_least(:once)
    expect(called).to be(true)
    expect(described_class.available?).to be(true)

    allow(adapter).to receive(:available?).and_return(false)

    expect(described_class.available?).to be(false)
  end

  it 'keeps one registration per channel when registration runs again' do
    adapter = class_double(Gitlab::Wecom::NotificationChannel, available?: true)
    2.times { described_class.register(:test_channel) { adapter } }

    expect { |block| described_class.each(&block) }.to yield_successive_args([:test_channel, adapter])
  end

  it 'fetches a channel by the name stored in job arguments' do
    adapter = class_double(Gitlab::Wecom::NotificationChannel, available?: true)
    described_class.register(:test_channel) { adapter }
    described_class.register(:broken) { raise NameError, 'channel failed' }

    expect(described_class.fetch('test_channel')).to eq(adapter)
    expect(described_class.fetch('broken')).to be_nil
    expect(described_class.fetch('unknown')).to be_nil
  end

  it 'skips a broken resolver and continues yielding healthy channels' do
    adapter = class_double(Gitlab::Wecom::NotificationChannel, available?: true)
    described_class.register(:broken) { raise NameError, 'channel failed' }
    described_class.register(:healthy) { adapter }

    expect { |block| described_class.each(&block) }.to yield_with_args(:healthy, adapter)
    expect(described_class.available?).to be(true)
  end

  it 'continues checking healthy channels after an availability error' do
    broken = class_double(Gitlab::Wecom::NotificationChannel)
    allow(broken).to receive(:available?).and_raise(StandardError, 'channel failed')
    described_class.register(:broken) { broken }
    described_class.register(:healthy) { class_double(Gitlab::Wecom::NotificationChannel, available?: true) }

    expect(described_class.available?).to be(true)
  end

  it 'treats a broken channel as unavailable without logging sensitive error messages #security' do
    described_class.register(:broken) { raise StandardError, 'secret credentials' }
    expect(Gitlab::AppLogger).to receive(:error).with(
      message: 'Could not resolve a notification channel', channel: 'broken',
      Labkit::Fields::ERROR_TYPE => 'StandardError'
    )

    expect(described_class.available?).to be(false)
  end
end
