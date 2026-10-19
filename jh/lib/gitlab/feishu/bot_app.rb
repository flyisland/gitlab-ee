# frozen_string_literal: true

module Gitlab
  module Feishu
    # The Feishu app behind the ChatOps robot, configured in the admin
    # application settings. Robot events arrive from this app, so replies and
    # cards must be sent with its token: Feishu only lets the app that created a
    # card update it. Separate from App, the sign-in and notification app.
    module BotApp
      API_SITE = 'https://open.feishu.cn'

      class << self
        def app_id
          ::Gitlab::CurrentSettings.feishu_app_key
        end

        def app_secret
          ::Gitlab::CurrentSettings.feishu_app_secret
        end

        # Internal apps get tenant tokens without one; part of the token cache key only.
        def tenant_key
          nil
        end

        def api_site
          API_SITE
        end

        def access_token
          AccessToken.fetch(app: self)
        end

        def invalidate_access_token
          AccessToken.invalidate(app: self)
        end
      end
    end
  end
end
