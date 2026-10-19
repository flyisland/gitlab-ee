# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Feishu::SendNotificationWorker, :clean_gitlab_redis_shared_state, feature_category: :integrations do
  let_it_be(:user, reload: true) { create(:user) }
  let_it_be(:identity, refind: true) do
    create(:identity, user: user, provider: 'feishu', extern_uid: 'tenant:cli_app:ou_user')
  end

  let(:attributes) { { 'title' => 'Review requested', 'url' => 'https://gitlab.example.com/review' } }
  let(:notification_id) { 'notification-uuid' }
  let(:endpoint) { 'https://open.feishu.test/open-apis/im/v1/messages?receive_id_type=open_id' }
  let(:response_body) { { code: 0 } }

  before do
    allow(Gitlab::Feishu::App).to receive_messages(notifications_available?: true,
      tenant_key: 'tenant', app_id: 'cli_app', api_site: 'https://open.feishu.test', access_token: 'token')
    allow(Gitlab::Feishu::NotificationIcon).to receive(:image_key).and_return('img_v2_icon')
    JH::Users::FeishuNotification.set(user, true)
    stub_request(:post, endpoint).to_return(status: 200, body: Gitlab::Json.generate(response_body))
  end

  def run
    described_class.new.perform(user.id, 'tenant:cli_app:ou_user', attributes, notification_id)
  end

  it 'sends to the bound user with a stable UUID' do
    request = stub_request(:post, endpoint)
      .with do |request|
      Gitlab::Json.parse(request.body).slice('receive_id', 'uuid') ==
        { 'receive_id' => 'ou_user', 'uuid' => notification_id }
    end
      .to_return(status: 200, body: '{"code":0}')

    run

    expect(request).to have_been_requested.once
  end

  it 'shows the uploaded instance icon on the card' do
    run

    expect(a_request(:post, endpoint).with do |request|
      Gitlab::Json.parse(Gitlab::Json.parse(request.body)['content']).dig('header', 'icon', 'img_key') == 'img_v2_icon'
    end).to have_been_made.once
  end

  [false, nil].each do |enabled|
    it "skips an opt-in of #{enabled.inspect}" do
      JH::Users::FeishuNotification.set(user, enabled)
      run

      expect(a_request(:post, endpoint)).not_to have_been_made
    end
  end

  it 'skips an unbound user' do
    identity.destroy!
    run

    expect(a_request(:post, endpoint)).not_to have_been_made
  end

  it 'skips untrusted identities #security' do
    identity.update!(trusted_extern_uid: false)
    run

    expect(a_request(:post, endpoint)).not_to have_been_made
  end

  it 'skips blocked users' do
    user.block!
    run

    expect(a_request(:post, endpoint)).not_to have_been_made
  end

  it 'stops delivery after the feature is disabled' do
    allow(Gitlab::Feishu::App).to receive(:notifications_available?).and_return(false)
    run

    expect(a_request(:post, endpoint)).not_to have_been_made
    expect(JH::Users::FeishuNotification.enabled_for?(user)).to be(true)
  end

  [:tenant_key, :app_id].each do |setting|
    it "rejects an old binding when #{setting} changes #security" do
      allow(Gitlab::Feishu::App).to receive(setting).and_return('changed')
      run

      expect(a_request(:post, endpoint)).not_to have_been_made
    end
  end

  context 'with a permanent failure' do
    let(:response_body) { { code: 230013 } }

    it 'logs and does not retry' do
      expect(Gitlab::AppLogger).to receive(:error).with(hash_including('message' => 'Feishu refused a notification'))
      expect { run }.not_to raise_error
    end
  end

  context 'with a transient failure' do
    let(:response_body) { { code: 5000 } }

    it 'lets Sidekiq retry the delivery' do
      expect { run }.to raise_error(Gitlab::Feishu::AppClient::TransientError)
    end
  end

  context 'when Feishu rate limits the delivery' do
    let(:job_args) { [user.id, 'tenant:cli_app:ou_user', attributes, notification_id] }

    before do
      stub_request(:post, endpoint).to_return(
        { status: 429, headers: { 'x-ogw-ratelimit-reset' => '7' }, body: '{"code":99991400}' },
        { status: 200, body: '{"code":0}' }
      )
    end

    it 'retries after the advertised delay and delivers with the same UUID', :aggregate_failures do
      error = nil
      expect { run }.to raise_error(Gitlab::Feishu::AppResponse::RateLimited) { |raised| error = raised }
      expect(described_class.sidekiq_retry_in_block.call(0, error)).to eq(7)

      expect { run }.not_to raise_error
      expect(a_request(:post, endpoint).with do |request|
        Gitlab::Json.parse(request.body)['uuid'] == notification_id
      end).to have_been_made.twice
    end

    it 'stops before the UUID deduplication window closes after accumulated backoff', :freeze_time do
      stub_request(:post, endpoint).to_timeout.then
        .to_return(status: 429, headers: { 'Retry-After' => '1800' }, body: '{"code":99991400}').times(2).then
        .to_return(status: 200, body: '{"code":0}')
      # The first request may have been delivered even though its response was lost.
      expect { run }.to raise_error(Gitlab::Feishu::AppClient::TransientError)

      travel(15.seconds)
      2.times do
        expect { run }.to raise_error(Gitlab::Feishu::AppResponse::RateLimited) { |error|
          expect(described_class.sidekiq_retry_in_block.call(1, error)).to eq(1800)
        }
        travel(1800.seconds)
      end

      expect(Gitlab::AppLogger).to receive(:warn)
        .with(hash_including('message' => 'Dropping a Feishu notification past its UUID deduplication window'))
      expect { run }.not_to raise_error
      expect(a_request(:post, endpoint)).to have_been_made.times(3)
    end

    it 'keeps the deadline from the first attempt rather than the latest retry', :freeze_time do
      stub_request(:post, endpoint).to_timeout.then.to_return(status: 200, body: '{"code":0}')
      expect { run }.to raise_error(Gitlab::Feishu::AppClient::TransientError)

      travel(described_class::SEND_DEADLINE - 1.second)
      run

      expect(a_request(:post, endpoint)).to have_been_made.twice
    end

    it 'keeps the default backoff when Feishu gives no usable delay', :aggregate_failures do
      expect(described_class.sidekiq_retry_in_block.call(0, Gitlab::Feishu::AppResponse::RateLimited.new)).to be_nil
      expect(described_class.sidekiq_retry_in_block.call(0, Gitlab::Feishu::AppClient::TransientError.new)).to be_nil
    end

    it 'stops after the retry budget', :aggregate_failures do
      expect(described_class.get_sidekiq_options['retry']).to eq(3)
      expect(Gitlab::AppLogger).to receive(:error).with(hash_including(message: 'Giving up on a Feishu notification'))

      described_class.sidekiq_retries_exhausted_block.call({ 'args' => job_args },
        Gitlab::Feishu::AppResponse::RateLimited.new)
    end
  end

  it_behaves_like 'an idempotent worker' do
    let(:job_args) { [user.id, 'tenant:cli_app:ou_user', attributes, notification_id] }
  end
end
