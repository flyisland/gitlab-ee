# frozen_string_literal: true

namespace :gitlab do
  namespace :dingtalk do
    desc 'GitLab | DingTalk | Register the Duo approval card callback with DingTalk'
    task :register_card_callback, [:url] => :environment do |_task, args|
      settings = Gitlab::CurrentSettings
      integration = Integrations::Dingtalk.find_by_corpid(settings.dingtalk_corpid)
      abort 'Activate the DingTalk integration first.' unless integration&.activated?

      # DingTalk takes whatever secret it is given, so one is made here when the
      # integration has none, and kept only once DingTalk has accepted it.
      secret = integration.card_callback_secret.presence || SecureRandom.hex(32)
      url = args[:url].presence || Gitlab::Dingtalk::CardCallback.default_url
      client = Gitlab::Dingtalk::Client.new(
        corpid: settings.dingtalk_corpid,
        app_key: settings.dingtalk_app_key,
        app_secret: settings.dingtalk_app_secret
      )
      # forceUpdate, so running this again after changing the secret or URL takes effect.
      response = client.register_card_callback(
        callbackUrl: url,
        callbackRouteKey: Gitlab::Dingtalk::CardCallback::ROUTE_KEY,
        apiSecret: secret,
        forceUpdate: true
      )

      unless response.respond_to?(:success?) && response.success?
        abort "DingTalk did not register the callback: #{response.respond_to?(:body) ? response.body : 'no response'}"
      end

      integration.update!(card_callback_secret: secret) if integration.card_callback_secret != secret

      puts "Registered #{url} as the DingTalk Duo approval card callback."
    end
  end
end
