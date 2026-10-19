# frozen_string_literal: true

module JH
  # User JH mixin
  #
  # This module is intended to encapsulate JH-specific model logic
  # and be prepended in the  model

  module MergeRequest
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    prepended do
      include ContentValidateable

      validates :title, :description, content_validation: true, if: :with_project_should_validate_content?

      # Safely extend KNOWN_MERGE_PARAMS to include skip_mono_central_pipeline
      original_params = const_get(:KNOWN_MERGE_PARAMS, false)
      silence_warnings do
        const_set(:KNOWN_MERGE_PARAMS, (original_params + [:skip_mono_central_pipeline]).freeze)
      end
    end

    def topic_label_name
      labels.find { |label| label.title.start_with?('topic::') }&.title
    end
  end
end
