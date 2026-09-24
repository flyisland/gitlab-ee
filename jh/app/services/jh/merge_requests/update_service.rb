# frozen_string_literal: true

module JH
  module MergeRequests
    module UpdateService
      include ::MergeRequests::ApprovalRulesAttributeMapping
      include ::MergeRequests::Concerns::MonoCentralPipeline
      extend ::Gitlab::Utils::Override

      override :handle_changes
      def handle_changes(merge_request, options)
        super

        return unless mono_central_pipeline_available?(merge_request.project)

        old_associations = options.fetch(:old_associations, {})
        old_labels = old_associations.fetch(:labels, [])
        handle_topic_label_changes(merge_request, old_labels)
      end

      private

      def handle_topic_label_changes(merge_request, old_labels)
        current_topic_label = extract_topic_label(merge_request.labels)
        old_topic_label = extract_topic_label(old_labels)
        ::Gitlab::AppLogger.info(
          "[monorepo] Topic changes from #{old_topic_label&.title} to #{current_topic_label&.title}")
        return if current_topic_label == old_topic_label

        # Determine which topic label to use for triggering the pipeline
        # Priority: current topic label, or the removed topic label if current is empty
        topic_label_to_trigger = current_topic_label.presence || old_topic_label

        trigger_mono_central_pipeline_for_topic_label(merge_request, topic_label_to_trigger, current_user)
      end
    end
  end
end
