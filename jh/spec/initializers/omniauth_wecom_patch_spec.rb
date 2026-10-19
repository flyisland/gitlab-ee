# frozen_string_literal: true

require 'spec_helper'

# The patch is what wires the standalone gem into GitLab. Its own specs stub the
# network one level lower, so nothing else catches a mistake in this wiring.
RSpec.describe 'OmniAuth WeCom patch', feature_category: :system_access do
  let(:corp_id) { 'ww_corp' }
  let(:corp_secret) { 'corp-secret' }
  let(:site) { 'https://wecom.test' }
  let(:code) { 'auth-code' }

  let(:strategy) do
    described = OmniAuth::Strategies::Wecom.new(
      ->(_env) { [200, {}, ['ok']] }, corp_id, corp_secret,
      agent_id: '1000002', client_options: { site: site }
    )
    allow(described).to receive(:request)
      .and_return(instance_double(Rack::Request, params: { 'code' => code }))
    described
  end

  it 'parses responses with the hardened parser' do
    expect(Gitlab::Json::SafeParser).to receive(:parse).with('{}').and_return({})

    strategy.send(:parse_json, '{}')
  end

  # Regression: the token call once used the hardcoded official endpoint while
  # the identity lookup followed the configured site, so the two halves of the
  # sign-in talked to different servers.
  it 'derives both calls from the same configured site' do
    expect(Gitlab::Wecom::AccessToken).to receive(:fetch).with(
      corp_id: corp_id,
      corp_secret: corp_secret,
      endpoint: "#{site}#{OmniAuth::Strategies::Wecom::TOKEN_PATH}"
    ).and_return(['token', 7200])

    strategy.send(:corp_access_token)

    expect(Gitlab::HTTP).to receive(:get).with(
      "#{site}#{OmniAuth::Strategies::Wecom::USER_INFO_PATH}",
      query: { access_token: 'token', code: code }
    )

    allow(strategy).to receive(:access_token)
      .and_return(instance_double(OAuth2::AccessToken, token: 'token'))
    strategy.send(:request_user_info)
  end

  it 'fetches member details through the controlled HTTP client too' do
    allow(strategy).to receive_messages(
      access_token: instance_double(OAuth2::AccessToken, token: 'token'),
      raw_user_info: { 'userid' => 'zhangsan' }
    )

    expect(Gitlab::HTTP).to receive(:get).with(
      "#{site}#{OmniAuth::Strategies::Wecom::USER_DETAIL_PATH}",
      query: { access_token: 'token', userid: 'zhangsan' }
    )

    strategy.send(:request_user_detail)
  end

  # Details are best-effort, so the strategy can only degrade gracefully if the
  # transport failure reaches it as a CallbackError.
  it 'reports a blocked or failed detail request as a CallbackError' do
    allow(strategy).to receive_messages(
      access_token: instance_double(OAuth2::AccessToken, token: 'token'),
      raw_user_info: { 'userid' => 'zhangsan' }
    )
    allow(Gitlab::HTTP).to receive(:get).and_raise(Gitlab::HTTP::BlockedUrlError)

    expect { strategy.send(:request_user_detail) }
      .to raise_error(OmniAuth::Strategies::OAuth2::CallbackError, /user detail request failed/)
  end

  it 'evicts the shared cache when WeCom rejects the token' do
    expect(Gitlab::Wecom::AccessToken).to receive(:invalidate)
      .with(corp_id: corp_id, corp_secret: corp_secret)

    strategy.send(:invalidate_access_token)
  end

  describe '#call', type: :strategy do
    let(:app) do
      OmniAuth::Strategies::Wecom.new(
        ->(_env) { [200, {}, ['ok']] }, corp_id, corp_secret,
        agent_id: '1000002', client_options: { site: site }, fetch_user_detail: true, path_prefix: '/auth'
      )
    end

    let(:callback_env) do
      Rack::MockRequest.env_for(
        "https://gitlab.example.com/auth/wecom/callback?code=#{code}&state=session-state",
        'rack.session' => { 'omniauth.state' => 'session-state' }
      )
    end

    let(:user_info_url) { "#{site}#{OmniAuth::Strategies::Wecom::USER_INFO_PATH}" }
    let(:user_detail_url) { "#{site}#{OmniAuth::Strategies::Wecom::USER_DETAIL_PATH}" }
    let(:user_info_body) { '{"errcode":0,"userid":"zhangsan"}' }
    let(:user_detail_body) { '{"errcode":0,"name":"Zhang San","email":"zhangsan@example.com"}' }

    before do
      allow(Gitlab::Wecom::AccessToken).to receive(:fetch).with(
        corp_id: corp_id, corp_secret: corp_secret, endpoint: "#{site}#{OmniAuth::Strategies::Wecom::TOKEN_PATH}"
      ).and_return(['token', 7200])
      allow(Gitlab::Json::SafeParser).to receive(:parse).and_call_original
      allow(Gitlab::HTTP).to receive(:get).with(
        user_info_url, query: { access_token: 'token', code: code }
      ).and_return(instance_double(HTTParty::Response, body: user_info_body))
      allow(Gitlab::HTTP).to receive(:get).with(
        user_detail_url, query: { access_token: 'token', userid: 'zhangsan' }
      ).and_return(instance_double(HTTParty::Response, body: user_detail_body))
    end

    it 'uses the controlled clients and parser during a real callback', :aggregate_failures do
      expect(app.call(callback_env).first).to eq(200)
      expect(callback_env.fetch('omniauth.auth')).to include(
        'uid' => "#{corp_id}:zhangsan",
        'info' => { 'name' => 'Zhang San', 'nickname' => 'zhangsan', 'email' => 'zhangsan@example.com' }
      )
      expect(Gitlab::Wecom::AccessToken).to have_received(:fetch).once
      expect(Gitlab::HTTP).to have_received(:get).with(
        user_info_url, query: { access_token: 'token', code: code }
      )
      expect(Gitlab::HTTP).to have_received(:get).with(
        user_detail_url, query: { access_token: 'token', userid: 'zhangsan' }
      )
      expect(Gitlab::Json::SafeParser).to have_received(:parse).with(user_info_body)
      expect(Gitlab::Json::SafeParser).to have_received(:parse).with(user_detail_body)
    end

    context 'when the shared token is rejected' do
      let(:user_info_body) { '{"errcode":40014,"errmsg":"invalid access_token"}' }

      before do
        allow(Gitlab::Wecom::AccessToken).to receive(:fetch)
          .and_return(['token', 7200], ['fresh-token', 7200])
        allow(Gitlab::Wecom::AccessToken).to receive(:invalidate)
        allow(Gitlab::HTTP).to receive(:get).with(
          user_info_url, query: { access_token: 'fresh-token', code: code }
        ).and_return(instance_double(HTTParty::Response, body: '{"errcode":0,"userid":"zhangsan"}'))
        allow(Gitlab::HTTP).to receive(:get).with(
          user_detail_url, query: { access_token: 'fresh-token', userid: 'zhangsan' }
        ).and_return(instance_double(HTTParty::Response, body: user_detail_body))
      end

      it 'invalidates the shared token and retries authentication', :aggregate_failures do
        expect(app.call(callback_env).first).to eq(200)
        expect(callback_env.fetch('omniauth.auth')['uid']).to eq("#{corp_id}:zhangsan")
        expect(Gitlab::Wecom::AccessToken).to have_received(:invalidate)
          .with(corp_id: corp_id, corp_secret: corp_secret).once
        expect(Gitlab::Wecom::AccessToken).to have_received(:fetch).twice
        expect(Gitlab::HTTP).to have_received(:get).with(
          user_info_url, query: { access_token: 'fresh-token', code: code }
        )
      end
    end

    context 'when the identity endpoint is blocked' do
      before do
        allow(Gitlab::HTTP).to receive(:get).with(
          user_info_url, query: { access_token: 'token', code: code }
        ).and_raise(Gitlab::HTTP::BlockedUrlError)
      end

      it 'does not authenticate the user', :aggregate_failures do
        expect(app.call(callback_env).first).to eq(302)
        expect(callback_env['omniauth.error']).to be_a(Gitlab::HTTP::BlockedUrlError)
        expect(callback_env).not_to have_key('omniauth.auth')
      end
    end
  end
end
