# frozen_string_literal: true

module MergeRequests
  class MergeRequestMonorepoEntity < Grape::Entity
    include RequestAwareEntity

    delegate :merge_requests_list_status,
      :other_merging_topic_label_name,
      :merge_user,
      :merge_requests,
      :merged_at,
      :central_pipeline,
      to: :monorepo_service

    expose :merge_requests_list_status
    expose :other_merging_topic_label_name
    expose :merge_user, using: API::Entities::UserPath
    expose :merged_at

    expose :has_permission_to_merge do |_|
      monorepo_service.has_permission_to_merge?(current_user)
    end

    expose :merge_requests do |_|
      monorepo_service.visible_merge_requests(current_user).map do |mr|
        {
          title: mr.title,
          path: project_merge_request_path(mr.project, mr),
          merge_error: mr.merge_error,
          mergeable: mr.mergeable?,
          state: mr.state,
          head_pipeline: DetailedStatusEntity.represent(
            monorepo_service.head_pipeline(mr)&.detailed_status(current_user)
          )&.as_json,
          breadcrumbs: mr.project.breadcrumbs,
          approvals_given: mr.approvals_given,
          approvals_left: mr.approvals_left
        }
      end
    end

    expose :central_pipeline, using: MergeRequests::PipelineEntity

    private

    def monorepo_service
      @monorepo_service ||= MergeRequests::MonorepoService.new(
        object.project.root_ancestor,
        object.topic_label_name
      )
    end

    def current_user
      request.current_user
    end
  end
end
