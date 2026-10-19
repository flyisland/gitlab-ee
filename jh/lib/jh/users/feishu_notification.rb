# frozen_string_literal: true

module JH
  module Users
    module FeishuNotification
      KEY = 'feishu_notifications_enabled'

      class << self
        def enabled_for?(user)
          return false unless user&.active?

          ::UserCustomAttribute.by_user_id(user.id).by_key(KEY).pick(:value) == 'true'
        end

        def set(user, enabled)
          ::UserCustomAttribute.upsert_custom_attributes(
            [{ user_id: user.id, key: KEY, value: enabled ? 'true' : 'false' }]
          )
        end

        def extern_uid_for(user)
          identity = user.identities.with_provider('feishu').first
          return unless identity&.trusted_extern_uid?

          identity.extern_uid
        end

        def open_id_for(extern_uid)
          ::Gitlab::Feishu::ExternUid.open_id_for(
            extern_uid, tenant_key: ::Gitlab::Feishu::App.tenant_key, app_id: ::Gitlab::Feishu::App.app_id
          )
        end
      end
    end
  end
end
