# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Notifications::FanoutWorker, feature_category: :integrations do
  let_it_be(:project) { create(:project, :private) }
  let_it_be(:user) { create(:user) }
  let_it_be(:issue, reload: true) { create(:issue, project: project) }
  let_it_be(:note, refind: true) do
    create(:note_on_issue, project: project, noteable: issue, note: 'Please review this change')
  end

  let(:args) { ActiveJob::Arguments.serialize([user.id, note.id, NotificationReason::MENTIONED]) }
  let(:kwargs) { ActiveJob::Arguments.serialize([{}]).first }
  let(:notification_id) { 'notification-uuid' }

  before_all do
    project.add_developer(user)
    create(:identity, user: user, provider: 'wecom', extern_uid: 'ww_corp:wecom_user')
    create(:identity, user: user, provider: 'feishu', extern_uid: 'tenant:cli_app:ou_user')
  end

  before do
    allow(Gitlab::Wecom::App).to receive_messages(notifications_available?: true, corp_id: 'ww_corp')
    allow(Gitlab::Feishu::App).to receive_messages(notifications_available?: true, tenant_key: 'tenant',
      app_id: 'cli_app')
    JH::Users::WecomNotification.set(user, true)
    JH::Users::FeishuNotification.set(user, true)
  end

  def run
    described_class.new.perform('note_issue_email', args, kwargs, notification_id)
    Notifications::ChannelEnqueueWorker.drain
  end

  it 'renders once and queues both channels with the same mail content' do
    expect(Notify).to receive(:new).once.and_call_original
    allow_next_instance_of(Gitlab::Notifications::Email) do |email|
      expect(email).to receive(:recipient).once.and_call_original
    end
    feishu_attributes = nil
    wecom_attributes = nil
    expect(Feishu::SendNotificationWorker).to receive(:perform_async) do |recipient, identity, content, uuid|
      expect(recipient).to eq(user.id)
      expect(identity).to eq('tenant:cli_app:ou_user')
      expect(uuid).to eq(notification_id)
      feishu_attributes = content
    end
    expect(Wecom::SendNotificationWorker).to receive(:perform_async) do |_event, payload|
      expect(payload['user_id']).to eq(user.id)
      expect(payload['attributes']['excerpt']).to include(note.note)
      expect(payload['attributes']['url']).to include("#note_#{note.id}")
      expect(payload['attributes']['reason']).to eq(NotificationReason::MENTIONED)
      wecom_attributes = payload['attributes']
    end

    run

    expect(feishu_attributes).to eq(wecom_attributes)
  end

  it 'does not re-render while delivering either prepared job' do
    wecom_job = nil
    feishu_job = nil
    allow(Wecom::SendNotificationWorker).to receive(:perform_async) { |*args| wecom_job = args }
    allow(Feishu::SendNotificationWorker).to receive(:perform_async) { |*args| feishu_job = args }
    allow(Gitlab::Feishu::NotificationIcon).to receive(:image_key).and_return('img_v2_icon')
    expect(Notify).to receive(:new).once.and_call_original
    allow_next_instance_of(Gitlab::Wecom::AppClient) do |client|
      expect(client).to receive(:send_card).with(['wecom_user'], kind_of(Hash)).and_return(
        Gitlab::Wecom::AppClient::Result.new(message_id: 'message-1', invalid_user_ids: [])
      )
    end
    allow_next_instance_of(Gitlab::Feishu::AppClient) do |client|
      expect(client).to receive(:send_card).with('ou_user', kind_of(Hash), uuid: notification_id)
    end

    run
    Wecom::SendNotificationWorker.new.perform(*wecom_job)
    Feishu::SendNotificationWorker.new.perform(*feishu_job)
  end

  it 'recovers a channel whose enqueue failed without queueing the other channel again', :aggregate_failures do
    feishu_uuids = []
    allow(Feishu::SendNotificationWorker).to receive(:perform_async) do |_user, _identity, _attributes, uuid|
      feishu_uuids << uuid
      raise ActiveRecord::ConnectionNotEstablished if feishu_uuids.one?
    end
    expect(Wecom::SendNotificationWorker).to receive(:perform_async).once
    expect(Notify).to receive(:new).once.and_call_original

    described_class.new.perform('note_issue_email', args, kwargs, notification_id)
    channel_jobs = Notifications::ChannelEnqueueWorker.jobs.map { |job| job['args'] }
    failed_jobs = channel_jobs.reject do |job_args|
      Notifications::ChannelEnqueueWorker.new.perform(*job_args)
    rescue ActiveRecord::ConnectionNotEstablished
      false
    else
      true
    end

    expect(failed_jobs.map(&:second)).to eq(['feishu'])

    # Sidekiq retries the failed channel job with its original arguments.
    failed_jobs.each { |job_args| Notifications::ChannelEnqueueWorker.new.perform(*job_args) }

    expect(feishu_uuids).to eq([notification_id, notification_id])
  end

  it 'lets Sidekiq retry the fanout when no channel job could be queued' do
    allow(Notifications::ChannelEnqueueWorker).to receive(:bulk_perform_async)
      .and_raise(Redis::BaseConnectionError)

    expect { described_class.new.perform('note_issue_email', args, kwargs, notification_id) }
      .to raise_error(Redis::BaseConnectionError)
  end

  it 'queues a channel whose availability check failed so its own job can retry' do
    allow(Gitlab::Feishu::App).to receive(:notifications_available?).and_raise(ActiveRecord::ConnectionNotEstablished)
    allow(Gitlab::AppLogger).to receive(:error)
    expect(Gitlab::AppLogger).to receive(:error)
      .with(hash_including('message' => 'Could not check a notification channel'))

    described_class.new.perform('note_issue_email', args, kwargs, notification_id)

    channel_names = Notifications::ChannelEnqueueWorker.jobs.map { |job| job['args'].second }

    expect(channel_names).to contain_exactly('wecom', 'feishu')
  end

  it 'skips disabled channels' do
    allow(Gitlab::Feishu::App).to receive(:notifications_available?).and_return(false)
    expect(Feishu::SendNotificationWorker).not_to receive(:perform_async)
    expect(Wecom::SendNotificationWorker).to receive(:perform_async)

    run
  end

  it 'does not render when all channels are unavailable' do
    allow(Gitlab::Feishu::App).to receive(:notifications_available?).and_return(false)
    allow(Gitlab::Wecom::App).to receive(:notifications_available?).and_return(false)
    expect(Notify).not_to receive(:new)

    run
  end

  it 'skips users who opted out' do
    JH::Users::WecomNotification.set(user, false)
    JH::Users::FeishuNotification.set(user, false)
    expect(Wecom::SendNotificationWorker).not_to receive(:perform_async)
    expect(Feishu::SendNotificationWorker).not_to receive(:perform_async)

    run
  end

  it 'removes confidential content before enqueueing either channel #security' do
    issue.update!(confidential: true)
    expect(Feishu::SendNotificationWorker).to receive(:perform_async) do |_user, _identity, attributes, _uuid|
      expect(attributes.values_at('project', 'reason', 'excerpt')).to all(be_nil)
      expect(attributes.to_s).not_to include(note.note)
      expect(attributes['title']).to include(issue.title)
    end
    expect(Wecom::SendNotificationWorker).to receive(:perform_async) do |_event, payload|
      expect(payload['attributes'].values_at('project', 'reason', 'excerpt')).to all(be_nil)
    end

    run
  end

  it_behaves_like 'an idempotent worker' do
    let(:job_args) { ['note_issue_email', args, kwargs, notification_id] }

    before do
      wecom_client = instance_double(Gitlab::Wecom::AppClient,
        send_card: Gitlab::Wecom::AppClient::Result.new(message_id: 'message', invalid_user_ids: []))
      allow(Gitlab::Wecom::AppClient).to receive(:new).and_return(wecom_client)
      allow(Gitlab::Feishu::AppClient).to receive(:new).and_return(instance_double(Gitlab::Feishu::AppClient,
        send_card: {}, upload_image: { 'code' => 0, 'data' => { 'image_key' => 'img_v2_icon' } }))
    end
  end

  it 'removes an internal note body from both channels #security' do
    note.update!(internal: true)
    expect(Feishu::SendNotificationWorker).to receive(:perform_async) do |_user, _identity, attributes, _uuid|
      expect(attributes.values_at('project', 'reason', 'excerpt')).to all(be_nil)
      expect(attributes.to_s).not_to include(note.note)
    end
    expect(Wecom::SendNotificationWorker).to receive(:perform_async) do |_event, payload|
      expect(payload['attributes'].values_at('project', 'reason', 'excerpt')).to all(be_nil)
    end

    run
  end
end
