# frozen_string_literal: true

module JH
  module Snippets
    module UpdateService
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      override :save_and_commit
      def save_and_commit(snippet)
        result = super

        # When change visibility_level from private to public or internal
        if ::ContentValidation::Setting.check_enabled?(snippet) &&
            snippet.saved_change_to_visibility_level? &&
            snippet.visibility_level_previously_was == ::Gitlab::VisibilityLevel::PRIVATE
          ::ContentValidation::ContainerService.new(container: snippet, user: current_user).execute
        end

        result
      end
    end
  end
end
