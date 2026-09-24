# frozen_string_literal: true

module MergeRequests
  module Concerns
    module MonoCentralPipeline
      extend ActiveSupport::Concern

      private

      def should_skip_mono_central_pipeline?(merge_request)
        skip_pipeline = merge_request.merge_params['skip_mono_central_pipeline'] ||
          merge_request.merge_params[:skip_mono_central_pipeline]
        result = skip_pipeline.present? && Gitlab::Utils.to_boolean(skip_pipeline)
        ::Gitlab::AppLogger.info(
          message: '[monorepo] should_skip_mono_central_pipeline?',
          merge_request_id: merge_request.id,
          skip_mono_central_pipeline: result
        )
        result
      end

      def mono_central_pipeline_available?(project)
        ::Gitlab::AppLogger.info(
          message: '[monorepo] Checking if central pipeline is available',
          project_id: project.id
        )
        ::MergeRequests::MonorepoService.monorepo_feature_available? &&
          ::Feature.enabled?(:ff_monorepo_topic_ci_trigger, project.root_ancestor, type: :ops)
      end

      def trigger_mono_central_pipeline_for_topic_label(merge_request, topic_label, current_user)
        ::Gitlab::AppLogger.info(
          message: '[monorepo] Triggering central pipeline for topic label',
          merge_request_id: merge_request.id,
          topic_label: topic_label&.title
        )
        return if topic_label.nil?

        begin
          monorepo_service = ::MergeRequests::MonorepoService.new(merge_request.project.root_ancestor,
            topic_label.title)
          monorepo_service.trigger_central_pipeline(current_user)
        rescue StandardError => e
          ::Gitlab::ErrorTracking.track_exception(e, merge_request_id: merge_request.id)
          nil
        end
      end

      def extract_topic_label(labels)
        labels.find { |label| label.title.start_with?('topic::') }
      end
    end
  end
end
