# frozen_string_literal: true

module JH
  # User JH mixin
  #
  # This module is intended to encapsulate JH-specific model logic
  # and be prepended in the  model

  module Snippet
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    prepended do
      include ContentValidateable
      validates :title, :description, content_validation: true, if: :should_validate_content?
    end

    # rubocop:disable Gitlab/StrongMemoizeAttr
    def content_blocked_states
      return [] unless ::ContentValidation::Setting.block_enabled?(self)

      strong_memoize(:content_blocked_states) { ::ContentValidation::ContentBlockedState.find_by_snippet(self) }
    end
    # rubocop:enable Gitlab/StrongMemoizeAttr
  end
end
