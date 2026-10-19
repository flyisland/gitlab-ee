# frozen_string_literal: true

module Gitlab
  module Dingtalk
    module Recipient
      KEY = 'dingtalk_notification_recipient'

      class << self
        def capture(user, oauth)
          return unless user&.persisted? && oauth['provider'] == App::PROVIDER && App.configured?

          identity = user.identities.with_extern_uid(App::PROVIDER, oauth['uid']).first
          return unless identity&.trusted_extern_uid?

          raw_info = oauth.dig('extra', 'raw_info')
          user_id = raw_info['userid'] if raw_info.is_a?(Hash)
          return log_missing_user_id unless valid_user_id?(user_id)
          return unless [raw_info['openid'], user_id].include?(oauth['uid'])

          value = scope(identity).merge('userid' => user_id)
          ::UserCustomAttribute.upsert_custom_attributes(
            [{ user_id: user.id, key: KEY, value: ::Gitlab::Json.generate(value) }]
          )
        rescue StandardError => e
          ::Gitlab::AppLogger.warn(
            message: 'Could not save the DingTalk notification recipient',
            Labkit::Fields::CLASS_NAME => name,
            Labkit::Fields::ERROR_TYPE => e.class.name
          )
        end

        def for_user(user)
          return unless user&.active? && App.configured?

          identity = user.identities.with_provider(App::PROVIDER).first
          return unless identity&.trusted_extern_uid?

          value = ::UserCustomAttribute.by_user_id(user.id).by_key(KEY).pick(:value)
          return if value.blank?

          mapping = ::Gitlab::Json::SafeParser.parse(value)
          return unless mapping.is_a?(Hash) && mapping.except('userid') == scope(identity)

          mapping['userid'] if valid_user_id?(mapping['userid'])
        rescue ::JSON::ParserError
          nil
        end

        def valid_user_id?(user_id)
          user_id.is_a?(String) && user_id.match?(/\A[a-zA-Z0-9_.@-]{1,64}\z/)
        end

        private

        # DingTalk omits the corporate userid when the app lacks the qyapi_get_member permission,
        # which otherwise leaves the binding without a recipient and no trace of why.
        def log_missing_user_id
          ::Gitlab::AppLogger.warn(
            message: 'DingTalk sign-in returned no corporate user ID; grant the app qyapi_get_member and reconnect',
            Labkit::Fields::CLASS_NAME => name
          )
        end

        def scope(identity)
          {
            'identity_id' => identity.id, 'extern_uid' => identity.extern_uid,
            'corp_id' => App.corp_id, 'app_id' => App.app_id, 'agent_id' => App.agent_id.to_s
          }
        end
      end
    end
  end
end
