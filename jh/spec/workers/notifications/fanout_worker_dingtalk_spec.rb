# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Notifications::FanoutWorker, feature_category: :integrations do
  include_context 'with DingTalk application'

  let_it_be(:project) { create(:project, :private) }
  let_it_be(:user) { create(:user) }
  let_it_be(:issue, reload: true) { create(:issue, project: project) }
  let_it_be(:note) { create(:note_on_issue, project: project, noteable: issue, note: 'Please review this change') }
  let(:notification_id) { 'notification-uuid' }
  let(:args) { ActiveJob::Arguments.serialize([user.id, note.id, NotificationReason::MENTIONED]) }
  let(:kwargs) { ActiveJob::Arguments.serialize([{}]).first }

  before_all do
    project.add_developer(user)
    create(:identity, user: user, provider: 'wecom', extern_uid: 'ww_corp:wecom_user')
    create(:identity, user: user, provider: 'dingtalk', extern_uid: 'openid')
  end

  before do
    allow(Gitlab::Wecom::App).to receive_messages(notifications_available?: true, corp_id: 'ww_corp')
    JH::Users::WecomNotification.set(user, true)
    JH::Users::DingtalkNotification.set(user, true)
    Gitlab::Dingtalk::Recipient.capture(user, OmniAuth::AuthHash.new(
      provider: 'dingtalk', uid: 'openid', extra: { raw_info: { openid: 'openid', userid: 'staff-123' } }
    ))
  end

  def run
    described_class.new.perform('note_issue_email', args, kwargs, notification_id)
    Notifications::ChannelEnqueueWorker.drain
  end

  it 'renders and extracts the email once for both registered channels' do
    expect(Notify).to receive(:new).once.and_call_original
    allow_next_instance_of(Gitlab::Notifications::Email) do |email|
      expect(email).to receive(:recipient).once.and_call_original
      expect(email).to receive(:attributes).once.and_call_original
    end
    expect(Wecom::SendNotificationWorker).to receive(:perform_async).once
    expect(Dingtalk::SendNotificationWorker).to receive(:perform_async).once

    run
  end

  it 'gives both channels the same recipient, event metadata and notification ID' do
    wecom_payload = nil
    dingtalk_args = nil
    allow(Wecom::SendNotificationWorker).to receive(:perform_async) { |_event, payload| wecom_payload = payload }
    allow(Dingtalk::SendNotificationWorker).to receive(:perform_async) { |*args| dingtalk_args = args }

    run

    expect(dingtalk_args).to include(user.id, 'staff-123', wecom_payload['attributes'], notification_id)
    expect(wecom_payload['user_id']).to eq(user.id)
    expect(wecom_payload['notification_id']).to eq(notification_id)
    expect(wecom_payload['attributes']).to include(
      'reason' => NotificationReason::MENTIONED, 'url' => a_string_including("#note_#{note.id}"),
      'excerpt' => a_string_including(note.note)
    )
  end

  it 'removes confidential content before either channel receives it #security' do
    issue.update!(confidential: true)
    expect(Wecom::SendNotificationWorker).to receive(:perform_async) do |_event, payload|
      expect(payload['attributes'].values_at('project', 'reason', 'excerpt')).to all(be_nil)
    end
    expect(Dingtalk::SendNotificationWorker).to receive(:perform_async) do |_user, _recipient, attributes, *_rest|
      expect(attributes.values_at('project', 'reason', 'excerpt')).to all(be_nil)
      expect(attributes.to_s).not_to include(note.note)
      expect(attributes['url']).to include("#note_#{note.id}")
    end

    run
  end

  it 'retries only the DingTalk channel job when DingTalk cannot be queued' do
    allow(Gitlab::Notifications::Channels).to receive(:each)
      .and_yield(:dingtalk, Gitlab::Dingtalk::NotificationChannel)
      .and_yield(:wecom, Gitlab::Wecom::NotificationChannel)
    allow(Dingtalk::SendNotificationWorker).to receive(:perform_async).and_raise(Redis::BaseError)
    expect(Wecom::SendNotificationWorker).to receive(:perform_async).once

    described_class.new.perform('note_issue_email', args, kwargs, notification_id)
    jobs = Notifications::ChannelEnqueueWorker.jobs.to_h { |job| [job['args'].second, job['args']] }

    expect { Notifications::ChannelEnqueueWorker.new.perform(*jobs.fetch('dingtalk')) }
      .to raise_error(Redis::BaseError)
    expect { Notifications::ChannelEnqueueWorker.new.perform(*jobs.fetch('wecom')) }.not_to raise_error
  end

  it 'removes internal comments on ordinary issues from both channels #security' do
    internal_note = create(:note_on_issue, :internal, project: project, noteable: issue, note: 'Internal comment only')
    expect(Wecom::SendNotificationWorker).to receive(:perform_async) do |_event, payload|
      expect(payload['attributes'].values_at('project', 'reason', 'excerpt')).to all(be_nil)
      expect(payload['attributes'].to_s).not_to include(internal_note.note)
    end
    expect(Dingtalk::SendNotificationWorker).to receive(:perform_async) do |_user, _recipient, attributes, *_rest|
      expect(attributes.values_at('project', 'reason', 'excerpt')).to all(be_nil)
      expect(attributes.to_s).not_to include(internal_note.note)
    end

    described_class.new.perform(
      'note_issue_email', ActiveJob::Arguments.serialize([user.id, internal_note.id]), kwargs, notification_id
    )
    Notifications::ChannelEnqueueWorker.drain
  end
end
