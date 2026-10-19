# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Notifications::ChannelEnqueueWorker, feature_category: :integrations do
  let_it_be(:user, reload: true) { create(:user) }

  let(:attributes) { { 'title' => 'Review requested', 'url' => 'https://gitlab.example.com/review' } }
  let(:channel) { class_double(Gitlab::Wecom::NotificationChannel, available?: true, enqueue: nil) }
  let(:job_args) { [user.id, 'test_channel', 'note_issue_email', attributes, 'notification-uuid'] }

  before do
    allow(Gitlab::Notifications::Channels).to receive(:fetch).and_call_original
    allow(Gitlab::Notifications::Channels).to receive(:fetch).with('test_channel').and_return(channel)
  end

  def run
    described_class.new.perform(*job_args)
  end

  it 'queues the named channel with the prepared content and notification ID' do
    run

    expect(channel).to have_received(:enqueue)
      .with(user, attributes, event: 'note_issue_email', notification_id: 'notification-uuid')
  end

  it 'skips a channel that is no longer registered' do
    job_args[1] = 'removed_channel'

    expect { run }.not_to raise_error
    expect(channel).not_to have_received(:enqueue)
  end

  it 'skips a channel that is no longer available' do
    allow(channel).to receive(:available?).and_return(false)
    run

    expect(channel).not_to have_received(:enqueue)
  end

  it 'skips a blocked user' do
    user.block!
    run

    expect(channel).not_to have_received(:enqueue)
  end

  it 'skips a deleted user' do
    job_args[0] = non_existing_record_id
    run

    expect(channel).not_to have_received(:enqueue)
  end

  it 'lets Sidekiq retry a transient failure' do
    allow(channel).to receive(:enqueue).and_raise(ActiveRecord::ConnectionNotEstablished)

    expect { run }.to raise_error(ActiveRecord::ConnectionNotEstablished)
  end

  it 'stops after the retry budget and logs the channel', :aggregate_failures do
    expect(described_class.get_sidekiq_options['retry']).to eq(3)
    expect(Gitlab::AppLogger).to receive(:error).with(hash_including(
      message: 'Giving up on queueing a notification channel', channel: 'test_channel',
      Labkit::Fields::ERROR_TYPE => 'ActiveRecord::ConnectionNotEstablished'
    ))

    described_class.sidekiq_retries_exhausted_block.call({ 'args' => job_args },
      ActiveRecord::ConnectionNotEstablished.new)
  end

  it_behaves_like 'an idempotent worker'
end
