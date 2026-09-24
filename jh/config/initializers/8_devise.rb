# frozen_string_literal: true

Devise.setup do |config|
  # inject cas3/dingtalk/wecom providers into devise omniauth providers in test env,
  # because upstream has removed all cas3/dingtalk config from the
  # gitlab.yml.example, and wecom is JH-only, so the feature test can't find
  # their sign-in buttons otherwise
  if Rails.env.test? && Gitlab::Auth.omniauth_enabled?
    cas3_provider = YAML.load_file(Rails.root.join('jh/spec/config/cas3.yml'))['test']['omniauth']['providers'][0]
    dingtalk_provider = { 'name' => 'dingtalk', :app_id => 'YOUR_APP_ID', :app_secret => 'YOUR_APP_SECRET' }
    wecom_provider = {
      'name' => 'wecom',
      'app_id' => 'YOUR_CORP_ID',
      'app_secret' => 'YOUR_CORP_SECRET',
      'args' => { 'agent_id' => 'YOUR_AGENT_ID' }
    }
    Gitlab::OmniauthInitializer.new(config).execute(
      [Gitlab::Configs::Options.build(cas3_provider), dingtalk_provider, wecom_provider]
    )
  end

  # override allow_unconfirmed_access_for
  break unless ::Gitlab.com? && ::Gitlab.jh?

  config.allow_unconfirmed_access_for = 60.days
end
