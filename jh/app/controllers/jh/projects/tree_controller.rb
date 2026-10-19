# frozen_string_literal: true

module JH
  module Projects
    module TreeController
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      prepended do
        before_action :set_content_blocked_state, only: [:show]
      end

      private

      def set_content_blocked_state
        return unless ::ContentValidation::Setting.block_enabled?(project)

        @content_blocked_state = ::ContentValidation::ContentBlockedState.find_by_container_commit_path(
          @project,
          @commit.id,
          @path)
      end
    end
  end
end
