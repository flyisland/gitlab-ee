# frozen_string_literal: true

RSpec.shared_context 'with DingTalk application' do
  let(:dingtalk_provider) do
    Gitlab::Configs::Options.build(
      'name' => 'dingtalk', 'app_id' => 'ding-app', 'app_secret' => 'app-secret',
      'args' => { 'corp_id' => 'ding-corp', 'agent_id' => '123456' }
    )
  end

  before do
    stub_omniauth_setting(enabled: true, providers: [dingtalk_provider])
    stub_licensed_features(dingtalk_app_integration: true)
    allow(Gitlab).to receive(:com?).and_return(false)
  end
end
