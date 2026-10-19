# frozen_string_literal: true

# The omniauth-wecom gem is standalone and knows nothing about GitLab. These
# overrides wire it into the application: a hardened JSON parser, the instance's
# controlled HTTP client, and the shared token cache so that signing in does not
# invalidate the token message delivery is using.
module OmniAuth
  module Strategies
    class Wecom
      protected

      def parse_json(raw)
        ::Gitlab::Json::SafeParser.parse(raw)
      end

      def request_user_info
        ::Gitlab::HTTP.get(
          "#{client.site}#{USER_INFO_PATH}",
          query: { access_token: access_token.token, code: request.params['code'] }
        )
      end

      # Member details are optional, so a transport failure is reported as a
      # CallbackError, which the strategy degrades to a userid-only `info`.
      # The identity lookup above deliberately has no such net.
      def request_user_detail
        ::Gitlab::HTTP.get(
          "#{client.site}#{USER_DETAIL_PATH}",
          query: { access_token: access_token.token, userid: raw_user_info['userid'] }
        )
      rescue ::Gitlab::HTTP::BlockedUrlError, *::Gitlab::HTTP::HTTP_ERRORS => e
        raise CallbackError.new(:invalid_credentials, "WeCom user detail request failed: #{e.class}")
      end

      # Both calls derive their host from the same configured site, so the token
      # and the identity lookup can never end up talking to different servers.
      def corp_access_token
        ::Gitlab::Wecom::AccessToken.fetch(
          corp_id: corp_id,
          corp_secret: client.secret,
          endpoint: "#{client.site}#{TOKEN_PATH}"
        )
      end

      def invalidate_access_token
        ::Gitlab::Wecom::AccessToken.invalidate(corp_id: corp_id, corp_secret: client.secret)
      end
    end
  end
end
