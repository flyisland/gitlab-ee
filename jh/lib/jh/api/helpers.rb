# frozen_string_literal: true

module JH
  module API
    module Helpers
      extend ::Gitlab::Utils::Override
      include ::Gitlab::HighAvailabilityChecker

      override :require_pages_enabled!
      def require_pages_enabled!
        not_found! unless user_project.pages_available?
      end

      def validate_free_license_ha!
        return unless should_block_instance?

        render_api_error!(
          '您当前实例订阅状态为极狐GitLab 基础版，并同时使用了专业版及旗舰版中的订阅功能"高可用架构"。请您购买新订阅：https://gitlab.cn/pricing',
          402
        )
      end
    end
  end
end
