# frozen_string_literal: true

module JH
  module Groups
    module CreateService
      extend ::Gitlab::Utils::Override

      private

      override :valid?
      def valid?
        valid_visibility_level? && valid_user_permissions?
      end
    end
  end
end
