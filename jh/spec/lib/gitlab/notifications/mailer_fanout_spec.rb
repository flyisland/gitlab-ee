# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Notifications::MailerFanout, feature_category: :integrations do
  let(:delivery) { instance_double(ActionMailer::MessageDelivery) }

  subject(:fanout) { described_class.new(Notify) }

  before do
    allow(Notify).to receive(:note_merge_request_email).and_return(delivery)
  end

  it 'hands back the delivery object untouched' do
    expect(fanout.note_merge_request_email(1, 2, nil)).to be(delivery)
  end

  it 'queues a WeCom notification for the same call' do
    expect(Notifications::FanoutWorker).to receive(:perform_async)
      .with('note_merge_request_email', [1, 2, 'mentioned'], anything, kind_of(String))

    fanout.note_merge_request_email(1, 2, 'mentioned')
  end

  it 'answers respond_to? on the mailer’s behalf' do
    expect(fanout).to respond_to(:note_merge_request_email)
    expect(fanout).not_to respond_to(:not_a_notification_email)
  end

  it 'swallows and reports a queueing failure' do
    allow(Notifications::FanoutWorker).to receive(:perform_async).and_raise(StandardError, 'boom')

    expect(Gitlab::AppLogger).to receive(:error)
      .with(hash_including(message: 'Could not queue notification cards'))

    expect { fanout.note_merge_request_email(1, 2, nil) }.not_to raise_error
  end
end
