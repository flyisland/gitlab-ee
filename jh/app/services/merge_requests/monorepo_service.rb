# frozen_string_literal: true

module MergeRequests
  class MonorepoService
    include Gitlab::Utils::StrongMemoize

    CAN_BE_MERGED = :can_be_merged
    CANNOT_BE_MERGED = :cannot_be_merged
    MERGED = :merged
    MERGING = :merging
    CLOSED = :closed

    CI_CENTRAL_PROJECT_NAME = 'monorepo-ci-project'
    CI_CENTRAL_PROJECT_DEFAULT_BRANCH = 'main'
    PIPELINE_TOPIC_LABEL_VARIABLE_KEY = 'MONOREPO_TOPIC_LABEL'
    CENTRAL_CI_PIPELINE_MUST_SUCCESS_VARIABLE_KEY = 'CENTRAL_CI_PIPELINE_MUST_SUCCESS'

    ObtainLeaseError = Class.new(StandardError)
    BulkMergeError = Class.new(StandardError)

    def self.monorepo_enabled?(merge_request)
      monorepo_feature_available? && merge_request_is_monorepo_mr?(merge_request)
    end

    def self.try_cancel_lease_if_possible!(merge_request_id)
      begin
        merge_request = MergeRequest.find(merge_request_id)
      rescue ActiveRecord::RecordNotFound
        return
      end

      return unless monorepo_enabled?(merge_request)

      monorepo_service = new(merge_request.project.root_ancestor, merge_request.topic_label_name)

      return unless monorepo_service.merge_is_done?

      monorepo_service.cancel_lease!
    end

    def self.monorepo_feature_available?
      !Gitlab.com? && Feature.enabled?(:ff_monorepo, type: :ops) && License.feature_available?(:monorepo)
    end

    def self.merge_request_is_monorepo_mr?(merge_request)
      merge_request.project.root_ancestor.is_a?(Group) &&
        merge_request.topic_label_name.present?
    end

    def initialize(root_group, topic_label_name)
      @root_group = root_group
      @topic_label_name = topic_label_name
    end

    def visible_merge_requests(current_user)
      MergeRequestsFinder.new(current_user, finder_options).execute
    end

    def head_pipeline(merge_request)
      return if merge_request.head_pipeline_id.nil?

      all_head_pipelines.find { |pipeline| pipeline.id == merge_request.head_pipeline_id }
    end

    def merge_requests_list_status
      return CANNOT_BE_MERGED unless other_merging_topic_label_name.nil?
      return MERGING if merging_topic_label_name == @topic_label_name
      return CLOSED if merge_requests.all?(&:closed?)
      return MERGED if opened_merge_requests.count == 0

      the_central_pipeline = central_pipeline(filter_by_precise_time_range: false)
      return CANNOT_BE_MERGED if the_central_pipeline && !the_central_pipeline.success? && \
        pipeline_has_variable_must_success?(the_central_pipeline)

      return CAN_BE_MERGED if opened_merge_requests.map(&:mergeable?).all?

      CANNOT_BE_MERGED
    end

    strong_memoize_attr :merge_requests_list_status

    def has_permission_to_merge?(current_user)
      opened_merge_requests.map { |mr| mr.can_be_merged_by?(current_user) }.all?
    end

    def other_merging_topic_label_name
      merging_topic_label_name if merging_topic_label_name != @topic_label_name
    end

    def merge_user
      last_merged_or_closed_mr&.metrics&.merged_by \
      || last_merged_or_closed_mr&.merge_user \
      || last_merged_or_closed_mr&.metrics&.latest_closed_by
    end

    def merged_at
      last_merged_or_closed_mr&.merged_at || last_merged_or_closed_mr&.metrics&.latest_closed_at
    end

    def bulk_merge!(current_user)
      check_merge_requests_list!(current_user)

      raise ObtainLeaseError if try_obtain_lease.nil?

      has_mr_merged_successfully = false
      opened_merge_requests.each do |mr|
        mr.update(merge_error: nil)
        mr.merge_async(
          current_user.id,
          mr.merge_params.merge(sha: mr.diff_head_sha)
        )
        has_mr_merged_successfully = true
      rescue StandardError
      end

      # Even if there is only one MR that is merging normally,
      # the code should not report an error.
      return if has_mr_merged_successfully

      cancel_lease!
      raise BulkMergeError
    end

    def ongoing_merge_requests
      merge_requests.reset.select(&:merge_ongoing?)
    end

    def merge_is_done?
      ongoing_merge_requests.count == 0
    end

    def cancel_lease!
      Gitlab::ExclusiveLease.cancel(lease_key, lease_value)
    end

    # "filter_by_precise_time_range" is used to solve the problem of circular references.
    def central_pipeline(filter_by_precise_time_range: true)
      return if ci_central_project.nil?

      pipelines = ::Ci::PipelinesFinder.new(
        ci_central_project,
        @root_group.owners.allow_cross_joins_across_databases(url: "https://jihulab.com/gitlab-cn/gitlab/-/issues/4002").first,
        central_pipeline_finder_params(filter_by_precise_time_range)
      ).execute

      pipelines.find do |pipeline|
        pipeline.variables.any? do |variable|
          variable.key == PIPELINE_TOPIC_LABEL_VARIABLE_KEY && variable.value == @topic_label_name
        end
      end
    end

    def pipeline_has_variable_must_success?(pipeline)
      pipeline.variables&.any? do |variable|
        variable.key == CENTRAL_CI_PIPELINE_MUST_SUCCESS_VARIABLE_KEY && ::Gitlab::Utils.to_boolean(variable.value)
      end
    end

    def trigger_central_pipeline(user)
      return if ci_central_project.nil? || user.nil?

      pipeline_variables = [
        {
          key: PIPELINE_TOPIC_LABEL_VARIABLE_KEY,
          value: @topic_label_name
        }
      ]
      pipeline_service = Ci::CreatePipelineService.new(
        ci_central_project,
        user,
        ref: CI_CENTRAL_PROJECT_DEFAULT_BRANCH,
        variables_attributes: pipeline_variables
      )
      pipeline_service.execute(:api, ignore_skip_ci: true)
    end

    private

    def try_obtain_lease
      Gitlab::ExclusiveLease.new(lease_key, uuid: lease_value, timeout: MergeRequest::MERGE_LEASE_TIMEOUT).try_obtain
    end

    def opened_merge_requests
      @opened_merge_requests ||= merge_requests.select(&:opened?)
    end

    def check_merge_requests_list!(current_user)
      raise Gitlab::Access::AccessDeniedError unless merge_requests_list_status == :can_be_merged
      raise Gitlab::Access::AccessDeniedError unless has_permission_to_merge?(current_user)
    end

    def finder_options
      {
        sort: "created_date",
        group_id: @root_group.id,
        label_name: @topic_label_name,
        non_archived: true,
        include_subgroups: true,
        attempt_group_search_optimizations: true
      }
    end

    # Returns all MRs in current MRs list
    # The query is not restricted by user permissions, so we use "owner" to initiate the query request
    def merge_requests
      @merge_requests ||= MergeRequestsFinder.new(
        @root_group.owners.allow_cross_joins_across_databases(url: "https://jihulab.com/gitlab-cn/gitlab/-/issues/4002").first,
        finder_options).execute
    end

    def merging_topic_label_name
      @merging_topic_label_name ||= Gitlab::ExclusiveLease.get_uuid(lease_key) || nil
    end

    def lease_key
      "jh:bulk_merge:rootgroup-#{@root_group.id}"
    end

    def lease_value
      @topic_label_name
    end

    def all_head_pipelines
      all_head_pipeline_ids = merge_requests.filter_map(&:head_pipeline_id).uniq
      Ci::Pipeline.where(id: all_head_pipeline_ids) # rubocop: disable CodeReuse/ActiveRecord -- we need to filter by id
    end

    strong_memoize_attr :all_head_pipelines

    def last_merged_or_closed_mr
      return unless merge_requests_list_status == :merged || merge_requests_list_status == :closed
      return if merge_requests.count == 0

      merged_merge_requests = merge_requests.filter(&:merged?)
      return merged_merge_requests.max_by(&:merged_at) if merged_merge_requests.count > 0

      merge_requests.last
    end

    strong_memoize_attr :last_merged_or_closed_mr

    def ci_central_project
      @ci_central_project ||= @root_group.projects.find_by_path(CI_CENTRAL_PROJECT_NAME)
    end

    def central_pipeline_finder_params(filter_by_precise_time_range)
      finder_params = { updated_after: merge_requests.first.created_at, ref: CI_CENTRAL_PROJECT_DEFAULT_BRANCH }

      if filter_by_precise_time_range &&
          (merge_requests_list_status == :merged || merge_requests_list_status == :closed)
        finder_params[:updated_before] = merged_at
      end

      finder_params
    end
  end
end
