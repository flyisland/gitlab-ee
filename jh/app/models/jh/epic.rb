# frozen_string_literal: true

module JH
  # User JH mixin
  #
  # This module is intended to encapsulate JH-specific model logic
  # and be prepended in the  model

  module Epic
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    prepended do
      include ContentValidateable

      validates :title, :description, content_validation: true, if: :should_validate_content?
    end
  end
end
