# frozen_string_literal: true

module JH
  module Users
    module DingtalkNotification
      KEY = 'dingtalk_notifications_enabled'

      class << self
        def enabled_for?(user)
          return false unless user

          ::UserCustomAttribute.by_user_id(user.id).by_key(KEY).pick(:value) == 'true'
        end

        def set(user, enabled)
          ::UserCustomAttribute.upsert_custom_attributes(
            [{ user_id: user.id, key: KEY, value: enabled ? 'true' : 'false' }]
          )
        end
      end
    end
  end
end
