# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Wecom::MailerFanout, feature_category: :integrations do
  let(:delivery) { instance_double(ActionMailer::MessageDelivery) }

  subject(:fanout) { described_class.new(Notify) }

  before do
    allow(Notify).to receive(:note_merge_request_email).and_return(delivery)
  end

  # Callers keep the delivery object, inspect it and deliver it themselves, so
  # anything other than the mailer's own return value gets in their way.
  it 'hands back the delivery object untouched' do
    expect(fanout.note_merge_request_email(1, 2, nil)).to be(delivery)
  end

  it 'queues a WeCom notification for the same call' do
    expect(Wecom::SendNotificationWorker).to receive(:perform_async)
      .with('note_merge_request_email', [1, 2, 'mentioned'], anything)

    fanout.note_merge_request_email(1, 2, 'mentioned')
  end

  # NotificationService asks before dispatching a pipeline email.
  it 'answers respond_to? on the mailer’s behalf' do
    expect(fanout).to respond_to(:note_merge_request_email)
    expect(fanout).not_to respond_to(:not_a_notification_email)
  end

  # The email is built by the time this runs. A WeCom problem must not cost it.
  it 'swallows and reports a queueing failure' do
    allow(Wecom::SendNotificationWorker).to receive(:perform_async).and_raise(StandardError, 'boom')

    expect(Gitlab::ErrorTracking).to receive(:track_exception)
      .with(kind_of(StandardError), hash_including(wecom_event: 'note_merge_request_email'))

    expect { fanout.note_merge_request_email(1, 2, nil) }.not_to raise_error
  end
end
