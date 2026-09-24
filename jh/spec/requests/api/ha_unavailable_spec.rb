# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'API when HA is blocked', feature_category: :not_owned do
  let_it_be(:user) { create(:user) }
  let(:token) { create(:personal_access_token, user: user, scopes: ['read_api']) }
  let(:message) do
    '您当前实例订阅状态为极狐GitLab 基础版，并同时使用了专业版及旗舰版中的订阅功能"高可用架构"。请您购买新订阅：https://gitlab.cn/pricing'
  end

  describe 'GET /api/v4/version' do
    context 'when instance is blocked' do
      before do
        allow_any_instance_of(Gitlab::HighAvailabilityChecker)
          .to receive(:should_block_instance?)
          .and_return(true)
      end

      it 'returns 402 with JSON error message' do
        get '/api/v4/version', headers: { 'ACCEPT' => 'application/json' }

        expect(response).to have_http_status(:payment_required)
        body = Gitlab::Json.parse(response.body)
        expect(body['message']).to eq(message)
      end
    end

    context 'when instance is not blocked' do
      before do
        allow_any_instance_of(Gitlab::HighAvailabilityChecker)
          .to receive(:should_block_instance?)
          .and_return(false)
      end

      it 'returns version info as normal' do
        get '/api/v4/version', headers: { 'ACCEPT' => 'application/json', 'Authorization' => "Bearer #{token.token}" }

        expect(response).to have_http_status(:ok)
        body = Gitlab::Json.parse(response.body)
        expect(body['version']).to be_present
      end
    end
  end
end
