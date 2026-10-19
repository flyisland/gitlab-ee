# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'gitlab:dingtalk:register_card_callback', :silence_stdout, feature_category: :duo_agent_platform do
  let(:url) { 'https://gitlab.example.com/api/v4/integrations/dingtalk/card_callback' }
  let(:registered) { {} }

  let(:integration) { create(:dingtalk_integration, :instance, corpid: 'dingtalk_corpid') }

  subject(:run_task) { run_rake_task('gitlab:dingtalk:register_card_callback', url) }

  before do
    Rake.application.rake_require('tasks/gitlab/dingtalk')

    stub_licensed_features(dingtalk_integration: true)
    stub_application_setting(dingtalk_integration_enabled: true, dingtalk_app_key: 'key',
      dingtalk_app_secret: 'secret', dingtalk_corpid: 'dingtalk_corpid')
    stub_request(:post, Gitlab::Dingtalk::Client::ACCESS_TOKEN_ENDPOINT)
      .to_return(status: 200, body: Gitlab::Json.generate({ accessToken: 'token', expireIn: 7200 }))
    integration
  end

  def stub_registration(status: 200)
    stub_request(:post, Gitlab::Dingtalk::Client::CARD_CALLBACK_REGISTER_ENDPOINT)
      .with { |req| registered.merge!(Gitlab::Json.parse(req.body)) }
      .to_return(status: status, body: Gitlab::Json.generate({ success: status == 200 }))
  end

  it 'makes a secret, registers it with DingTalk and keeps it', :aggregate_failures do
    stub_registration

    run_task

    secret = integration.reload.card_callback_secret
    expect(secret).to match(/\A\h{64}\z/)
    expect(registered).to include('callbackUrl' => url, 'callbackRouteKey' => 'gitlab-duo-approval',
      'apiSecret' => secret, 'forceUpdate' => true)
  end

  it 'registers the secret the integration already has' do
    integration.update!(card_callback_secret: 'chosen-secret')
    stub_registration

    run_task

    expect(registered['apiSecret']).to eq('chosen-secret')
  end

  it 'keeps no secret DingTalk did not accept', :aggregate_failures do
    stub_registration(status: 400)

    expect { run_task }.to raise_error(SystemExit)
    expect(integration.reload.card_callback_secret).to be_nil
  end

  it 'refuses without an active integration' do
    integration.update_column(:active, false)

    expect { run_task }.to raise_error(SystemExit)
  end
end
