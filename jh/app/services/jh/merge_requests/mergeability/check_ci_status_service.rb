# frozen_string_literal: true

module JH
  module MergeRequests
    module Mergeability
      module CheckCiStatusService
        extend ::Gitlab::Utils::Override

        override :mergeable_ci_state?
        def mergeable_ci_state?
          return super unless ::MergeRequests::MonorepoService.monorepo_enabled?(merge_request)
          return super if merge_request.diff_head_pipeline

          # The following code logic refers to the Upstream code "MergeRequest#mergeable_ci_state?"
          requires_successful_pipeline =
            merge_request.only_allow_merge_if_pipeline_succeeds? ||
            (merge_request.auto_merge_strategy == ::AutoMergeService::STRATEGY_MERGE_WHEN_CHECKS_PASS &&
              merge_request.has_ci_enabled?)

          return true unless requires_successful_pipeline

          return false unless mono_central_pipeline

          return true if merge_request.project.allow_merge_on_skipped_pipeline?(inherit_group_setting: true) &&
            mono_central_pipeline.skipped?

          mono_central_pipeline.success?
        end

        def mono_central_pipeline
          monorepo_service = ::MergeRequests::MonorepoService.new(merge_request.project.root_ancestor,
            merge_request.topic_label_name)
          monorepo_service.central_pipeline(filter_by_precise_time_range: false)
        end
      end
    end
  end
end
