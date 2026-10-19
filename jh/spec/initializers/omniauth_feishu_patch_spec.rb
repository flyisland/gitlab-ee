# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'OmniAuth Feishu patch', type: :strategy, feature_category: :system_access do
  include DeviseHelpers

  around do |example|
    with_omniauth_full_host { example.run }
  end

  let(:site) { 'https://open.feishu.test' }
  let(:token_url) { 'https://accounts.feishu.test/oauth/v3/token' }
  let(:strategy) do
    OmniAuth::Strategies::Feishu.new(
      ->(_env) { [200, {}, ['ok']] }, 'cli_app', 'app-secret',
      tenant_key: 'tenant', path_prefix: '/auth',
      client_options: { site: site, token_url: token_url }
    )
  end

  let(:callback_env) do
    Rack::MockRequest.env_for(
      'https://gitlab.example.com/auth/feishu/callback?code=auth-code&state=session-state',
      'rack.session' => { 'omniauth.state' => 'session-state' }
    )
  end

  let(:token_body) { { code: 0, access_token: 'user-token', expires_in: 7200 } }
  let(:user_data) { { tenant_key: 'tenant', open_id: 'ou_user', name: 'Test User', email: 'untrusted@example.com' } }
  let(:user_body) { { code: 0, data: user_data } }

  before do
    allow(Gitlab).to receive(:com?).and_return(false)
    stub_request(:post, token_url).with(
      body: { grant_type: 'authorization_code', client_id: 'cli_app', client_secret: 'app-secret',
              code: 'auth-code', redirect_uri: 'https://gitlab.example.com/auth/feishu/callback' }
    ).to_return(status: 200, body: Gitlab::Json.generate(token_body))
    stub_request(:get, "#{site}/open-apis/authen/v1/user_info")
      .with(headers: { 'Authorization' => 'Bearer user-token' })
      .to_return(status: 200, body: Gitlab::Json.generate(user_body))
  end

  it 'authenticates the tenant-scoped identity through the controlled HTTP client', :aggregate_failures do
    expect(Gitlab::HTTP).to receive(:post).and_call_original
    expect(Gitlab::HTTP).to receive(:get).and_call_original
    expect(Gitlab::Json::SafeParser).to receive(:parse).with(Gitlab::Json.generate(token_body)).and_call_original
    expect(Gitlab::Json::SafeParser).to receive(:parse).with(Gitlab::Json.generate(user_body)).and_call_original

    expect(strategy.call(callback_env).first).to eq(200)
    auth = callback_env.fetch('omniauth.auth')
    expect(auth['uid']).to eq('tenant:cli_app:ou_user')
    expect(auth['info']).to eq('name' => 'Test User', 'nickname' => 'ou_user')
    expect(auth['credentials']).to be_empty
    expect(auth.to_s).not_to include('user-token', 'app-secret', 'untrusted@example.com')
  end

  it 'uses state without PKCE in the authorization request' do
    env = Rack::MockRequest.env_for('https://gitlab.example.com/auth/feishu', 'rack.session' => {})
    strategy.call!(env)
    params = strategy.authorize_params

    expect(params[:state]).to be_present
    expect(params).not_to have_key(:code_challenge)
    expect(params).not_to have_key(:code_challenge_method)
    expect(env['rack.session']).not_to have_key('omniauth.pkce.verifier')
  end

  it 'rejects a mismatched state before making any external request #security' do
    callback_env['rack.session']['omniauth.state'] = 'other-state'
    expect(Gitlab::HTTP).not_to receive(:post)

    expect(strategy.call(callback_env).first).to eq(302)
    expect(callback_env['omniauth.error.type']).to eq(:csrf_detected)
  end

  it 'rejects reused callbacks #security' do
    strategy.call(callback_env)
    callback_env.delete('omniauth.auth')

    expect(strategy.call(callback_env).first).to eq(302)
    expect(callback_env).not_to have_key('omniauth.auth')
  end

  it 'fails closed for a blocked endpoint without exposing the exception message' do
    allow(Gitlab::HTTP).to receive(:post).and_raise(Gitlab::HTTP::BlockedUrlError, 'app-secret auth-code')

    expect(strategy.call(callback_env).first).to eq(302)
    expect(callback_env['omniauth.error'].message).not_to include('app-secret', 'auth-code')
    expect(callback_env).not_to have_key('omniauth.auth')
  end

  it 'disables login on SaaS' do
    allow(Gitlab).to receive(:com?).and_return(true)
    expect(Gitlab::HTTP).not_to receive(:post)

    expect(strategy.call(callback_env).first).to eq(302)
  end

  context 'when the tenant does not match' do
    let(:user_data) { { tenant_key: 'another-tenant', open_id: 'ou_user' } }

    it 'does not authenticate #security' do
      expect(strategy.call(callback_env).first).to eq(302)
      expect(callback_env).not_to have_key('omniauth.auth')
    end
  end

  context 'when the open ID is missing' do
    let(:user_data) { { tenant_key: 'tenant', user_id: 'user' } }

    it 'does not fall back to a different identifier' do
      expect(strategy.call(callback_env).first).to eq(302)
      expect(callback_env).not_to have_key('omniauth.auth')
    end
  end

  context 'when the token response is invalid' do
    let(:token_body) { { code: '0', access_token: 'user-token', expires_in: 7200 } }

    it 'rejects the response without authenticating' do
      expect(strategy.call(callback_env).first).to eq(302)
      expect(callback_env).not_to have_key('omniauth.auth')
    end
  end
end
