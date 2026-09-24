# frozen_string_literal: true

module JH
  module Users
    # Answers whether a user should receive WeCom notifications, and where to
    # send them.
    #
    # The opt-in lives in user_custom_attributes rather than in a column on
    # user_preferences: that table belongs to upstream, which is free to rename
    # or drop what it holds, and JH avoids adding columns there.
    module WecomNotification
      KEY = 'wecom_notifications_enabled'
      ENABLED = 'true'
      DISABLED = 'false'

      class << self
        def enabled_for?(user)
          return false if user.nil?

          ::UserCustomAttribute.by_user_id(user.id).by_key(KEY).pick(:value) == ENABLED
        end

        def set(user, enabled)
          ::UserCustomAttribute.upsert_custom_attributes(
            [{ user_id: user.id, key: KEY, value: enabled ? ENABLED : DISABLED }]
          )
        end

        # Resolves the WeCom UserId of a bound account.
        #
        # The identity carries the CorpID it was created under. If the instance
        # now points at a different company, the binding is stale and must not
        # be used: the same UserId there belongs to somebody else.
        def wecom_user_id_for(user)
          extern_uid = user.identities
            .with_provider(::Gitlab::Wecom::ExternUid::PROVIDER)
            .pick(:extern_uid)
          return if extern_uid.nil?

          ::Gitlab::Wecom::ExternUid.user_id_for(extern_uid, ::Gitlab::Wecom::App.corp_id)
        end
      end
    end
  end
end
