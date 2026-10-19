# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Dingtalk::Recipient, feature_category: :integrations do
  include_context 'with DingTalk application'

  let_it_be(:user, reload: true) { create(:user) }
  let!(:identity) { create(:identity, user: user, provider: 'dingtalk', extern_uid: 'old-openid') }
  let(:oauth) do
    OmniAuth::AuthHash.new(
      provider: 'dingtalk', uid: identity.extern_uid,
      extra: { raw_info: { openid: 'old-openid', userid: 'staff-123' } }
    )
  end

  def capture
    described_class.capture(user, oauth)
  end

  it 'never interprets an existing extern_uid as a recipient' do
    expect(described_class.for_user(user)).to be_nil
  end

  it 'records the corporate userid without changing the login identity', :aggregate_failures do
    expect { capture }.not_to change { identity.reload.extern_uid }
    expect(described_class.for_user(user)).to eq('staff-123')
  end

  it 'also accepts a verified userid login identity' do
    identity.update!(extern_uid: 'staff-123')
    capture

    expect(described_class.for_user(user)).to eq('staff-123')
  end

  it 'captures independently of the notification feature flag' do
    stub_feature_flags(jh_dingtalk_app_notification: false)
    capture

    expect(described_class.for_user(user)).to eq('staff-123')
  end

  %w[corp_id agent_id].each do |key|
    it "rejects a mapping after #{key} changes" do
      capture
      dingtalk_provider['args'][key] = '987654'

      expect(described_class.for_user(user)).to be_nil
    end
  end

  it 'rejects a mapping after the application changes' do
    capture
    dingtalk_provider['app_id'] = 'another-app'

    expect(described_class.for_user(user)).to be_nil
  end

  it 'rejects a mapping after unlinking and relinking the same identity' do
    capture
    identity.destroy!
    create(:identity, user: user, provider: 'dingtalk', extern_uid: 'old-openid')

    expect(described_class.for_user(user)).to be_nil
  end

  it 'rejects an untrusted login identity' do
    identity.update!(trusted_extern_uid: false)
    capture

    expect(described_class.for_user(user)).to be_nil
  end

  it 'rejects an unrelated authenticated account' do
    oauth['uid'] = 'someone-else'
    capture

    expect(described_class.for_user(user)).to be_nil
  end

  it 'does not fall back to openid when userid is missing' do
    oauth['extra']['raw_info'].delete('userid')
    capture

    expect(described_class.for_user(user)).to be_nil
  end

  it 'logs a missing userid so a missing member permission can be diagnosed' do
    oauth['extra']['raw_info'].delete('userid')
    expect(Gitlab::AppLogger).to receive(:warn).with(hash_including(
      message: 'DingTalk sign-in returned no corporate user ID; grant the app qyapi_get_member and reconnect'
    ))

    capture
  end

  it 'rejects injected recipient lists' do
    oauth['extra']['raw_info']['userid'] = 'staff-123,another-user'
    capture

    expect(described_class.for_user(user)).to be_nil
  end

  it 'skips blocked users' do
    capture
    user.block!

    expect(described_class.for_user(user)).to be_nil
  end

  it 'does not interrupt authentication if storage fails' do
    allow(UserCustomAttribute).to receive(:upsert_custom_attributes).and_raise(ActiveRecord::StatementInvalid)

    expect { capture }.not_to raise_error
  end

  it 'ignores malformed stored mappings' do
    UserCustomAttribute.upsert_custom_attributes([{ user_id: user.id, key: described_class::KEY, value: 'invalid' }])

    expect(described_class.for_user(user)).to be_nil
  end
end
