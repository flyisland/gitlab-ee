# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OmniauthCallbacksController, feature_category: :system_access do
  include LoginHelpers
  include_context 'with DingTalk application'

  let_it_be(:user) { create(:user) }
  let(:oauth) do
    OmniAuth::AuthHash.new(
      provider: 'dingtalk', uid: 'old-openid', info: { name: user.name, email: user.email },
      extra: { raw_info: { openid: 'old-openid', userid: 'staff-123' } }
    )
  end

  before do
    prepare_provider_route('dingtalk')
    request.env['devise.mapping'] = Devise.mappings[:user]
    request.env['omniauth.auth'] = oauth
    stub_feature_flags(jh_dingtalk_app_notification: false)
    sign_in(user)
  end

  it 'records a recipient after the signed-in user links DingTalk', :aggregate_failures do
    post :dingtalk

    expect(user.identities.with_provider('dingtalk').pick(:extern_uid)).to eq('old-openid')
    expect(Gitlab::Dingtalk::Recipient.for_user(user)).to eq('staff-123')
  end

  it 'does not record a recipient when the identity belongs to another user' do
    create(:identity, provider: 'dingtalk', extern_uid: 'old-openid')
    post :dingtalk

    expect(Gitlab::Dingtalk::Recipient.for_user(user)).to be_nil
  end
end
