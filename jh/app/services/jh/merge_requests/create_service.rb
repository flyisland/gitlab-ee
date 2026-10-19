# frozen_string_literal: true

module JH
  module MergeRequests
    module CreateService
      include ::MergeRequests::Concerns::MonoCentralPipeline
      extend ::Gitlab::Utils::Override

      override :after_create
      def after_create(merge_request)
        super

        return unless mono_central_pipeline_available?(merge_request.project)
        return if should_skip_mono_central_pipeline?(merge_request)

        topic_label = extract_topic_label(merge_request.labels)
        trigger_mono_central_pipeline_for_topic_label(merge_request, topic_label, current_user)
      end
    end
  end
end
