# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Notifications::FanoutWorker, feature_category: :integrations do
  let_it_be(:project) { create(:project, :private) }
  let_it_be(:user) { create(:user) }
  let_it_be(:issue, reload: true) { create(:issue, project: project) }
  let_it_be(:note) { create(:note_on_issue, project: project, noteable: issue, note: 'Please review this change') }
  let(:args) { ActiveJob::Arguments.serialize([user.id, note.id, NotificationReason::MENTIONED]) }
  let(:kwargs) { ActiveJob::Arguments.serialize([{}]).first }
  let(:notification_id) { 'notification-uuid' }

  before_all do
    project.add_developer(user)
    create(:identity, user: user, provider: 'wecom', extern_uid: 'ww_corp:wecom_user')
  end

  before do
    allow(Gitlab::Wecom::App).to receive_messages(notifications_available?: true, corp_id: 'ww_corp')
    allow(Gitlab::Notifications::Channels).to receive(:each).and_yield(:wecom, Gitlab::Wecom::NotificationChannel)
    JH::Users::WecomNotification.set(user, true)
  end

  def run
    described_class.new.perform('note_issue_email', args, kwargs, notification_id)
    Notifications::ChannelEnqueueWorker.drain
  end

  it 'renders once and resolves the recipient from the mail' do
    expect(Notify).to receive(:new).once.and_call_original
    allow_next_instance_of(Gitlab::Notifications::Email) do |email|
      expect(email).to receive(:recipient).once.and_call_original
    end
    expect(Wecom::SendNotificationWorker).to receive(:perform_async) do |event, payload|
      expect(event).to eq('note_issue_email')
      expect(payload['user_id']).to eq(user.id)
      expect(payload['attributes']['excerpt']).to include(note.note)
      expect(payload['attributes']['url']).to include("#note_#{note.id}")
      expect(payload['attributes']['reason']).to eq(NotificationReason::MENTIONED)
    end

    run
  end

  it 'does not render when all channels are unavailable' do
    allow(Gitlab::Notifications::Channels).to receive(:available?).and_return(false)
    expect(Notify).not_to receive(:new)

    run
  end

  it 'skips a user who opted out' do
    JH::Users::WecomNotification.set(user, false)
    expect(Wecom::SendNotificationWorker).not_to receive(:perform_async)

    run
  end

  it 'does not enqueue after the recipient loses their binding' do
    user.identities.with_provider('wecom').delete_all
    expect(Wecom::SendNotificationWorker).not_to receive(:perform_async)

    run
  end

  it 'drops mail whose source no longer exists' do
    expect(Wecom::SendNotificationWorker).not_to receive(:perform_async)
    note.destroy!

    run
  end

  it 'removes confidential content before enqueueing #security' do
    issue.update!(confidential: true)
    expect(Wecom::SendNotificationWorker).to receive(:perform_async) do |_event, payload|
      expect(payload['attributes'].values_at('project', 'reason', 'excerpt')).to all(be_nil)
      expect(payload['attributes'].to_s).not_to include(note.note)
    end

    run
  end

  it_behaves_like 'an idempotent worker' do
    let(:job_args) { ['note_issue_email', args, kwargs, notification_id] }

    before do
      client = instance_double(Gitlab::Wecom::AppClient,
        send_card: Gitlab::Wecom::AppClient::Result.new(message_id: 'message', invalid_user_ids: []))
      allow(Gitlab::Wecom::AppClient).to receive(:new).and_return(client)
    end
  end
end
