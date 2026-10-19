# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Dingtalk::NotificationChannel, feature_category: :integrations do
  include_context 'with DingTalk application'

  let_it_be(:user) { create(:user) }
  let!(:identity) { create(:identity, user: user, provider: 'dingtalk', extern_uid: 'openid') }
  let(:attributes) { { 'title' => 'Title', 'url' => 'https://example.com/issue' } }

  before do
    Gitlab::Dingtalk::Recipient.capture(user, OmniAuth::AuthHash.new(
      provider: 'dingtalk', uid: 'openid', extra: { raw_info: { openid: 'openid', userid: 'staff-123' } }
    ))
  end

  def enqueue
    described_class.enqueue(user, attributes, event: 'note_issue_email', notification_id: 'notification-uuid')
  end

  it 'queues only JSON-native arguments for an opted-in bound user' do
    JH::Users::DingtalkNotification.set(user, true)

    expect(Dingtalk::SendNotificationWorker).to receive(:perform_async).with(
      user.id, 'staff-123', attributes, 'notification-uuid',
      { 'corp_id' => 'ding-corp', 'app_id' => 'ding-app', 'agent_id' => '123456' }
    )

    enqueue
  end

  it 'does not notify users who have only bound their account' do
    expect(Dingtalk::SendNotificationWorker).not_to receive(:perform_async)

    enqueue
  end

  it 'does not notify unlinked users' do
    JH::Users::DingtalkNotification.set(user, true)
    identity.destroy!
    expect(Dingtalk::SendNotificationWorker).not_to receive(:perform_async)

    enqueue
  end

  it 'checks the instance gate before queueing' do
    JH::Users::DingtalkNotification.set(user, true)
    stub_feature_flags(jh_dingtalk_app_notification: false)
    expect(Dingtalk::SendNotificationWorker).not_to receive(:perform_async)

    enqueue
  end
end
