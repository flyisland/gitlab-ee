# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Dingtalk::SendNotificationWorker, :use_clean_rails_memory_store_caching,
  feature_category: :integrations do
  include_context 'with DingTalk application'

  let_it_be(:user) { create(:user) }
  let!(:identity) { create(:identity, user: user, provider: 'dingtalk', extern_uid: 'openid') }
  let(:attributes) { { 'title' => 'Title', 'excerpt' => 'Comment', 'url' => 'https://example.com/issue' } }
  let(:app_scope) { { 'corp_id' => 'ding-corp', 'app_id' => 'ding-app', 'agent_id' => '123456' } }
  let(:job_args) { [user.id, 'staff-123', attributes, 'notification-uuid', app_scope] }
  let(:request) do
    stub_request(:post, Gitlab::Dingtalk::AppClient::ENDPOINT)
      .with(query: { access_token: 'token' })
      .to_return(body: { errcode: 0, task_id: 123 }.to_json)
  end

  before do
    Gitlab::Dingtalk::Recipient.capture(user, OmniAuth::AuthHash.new(
      provider: 'dingtalk', uid: 'openid', extra: { raw_info: { openid: 'openid', userid: 'staff-123' } }
    ))
    JH::Users::DingtalkNotification.set(user, true)
    allow(Gitlab::Dingtalk::App).to receive(:access_token).and_return('token')
    request
  end

  def perform
    described_class.new.perform(*job_args)
  end

  it 'delivers a card once across duplicate executions' do
    2.times { perform }

    expect(request).to have_been_requested.once
  end

  it_behaves_like 'an idempotent worker' do
    it 'sends one external message' do
      perform_idempotent_work

      expect(request).to have_been_requested.once
    end
  end

  it 'stops delivery when the feature flag is disabled' do
    stub_feature_flags(jh_dingtalk_app_notification: false)
    perform

    expect(request).not_to have_been_requested
  end

  it 'stops delivery after opting out' do
    JH::Users::DingtalkNotification.set(user, false)
    perform

    expect(request).not_to have_been_requested
  end

  it 'stops delivery after unlinking' do
    identity.destroy!
    perform

    expect(request).not_to have_been_requested
  end

  it 'rejects a queued payload from a different enterprise' do
    app_scope['corp_id'] = 'old-corp'
    perform

    expect(request).not_to have_been_requested
  end

  it 'does not retry permanent errors' do
    stub_request(:post, Gitlab::Dingtalk::AppClient::ENDPOINT)
      .with(query: { access_token: 'token' }).to_return(body: { errcode: 90018 }.to_json)

    expect { perform }.not_to raise_error
  end

  it 'allows Sidekiq to retry transient errors' do
    stub_request(:post, Gitlab::Dingtalk::AppClient::ENDPOINT)
      .with(query: { access_token: 'token' }).to_return(status: 503)

    expect { perform }.to raise_error(Gitlab::Dingtalk::AppClient::TransientError)
  end
end
