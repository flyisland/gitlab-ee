# frozen_string_literal: true

module Gitlab
  module Feishu
    module ExternUid
      class << self
        def open_id_for(extern_uid, tenant_key:, app_id:)
          return unless extern_uid.is_a?(String)

          parts = extern_uid.split(':', -1)
          return unless parts.size == 3 && parts.all? { |part| identifier?(part) }
          return unless parts[0] == tenant_key && parts[1] == app_id

          parts[2]
        end

        private

        def identifier?(value)
          value.is_a?(String) && value.match?(/\A[A-Za-z0-9_-]+\z/)
        end
      end
    end
  end
end
