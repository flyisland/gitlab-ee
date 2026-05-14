# frozen_string_literal: true

module MergeRequests
  module ReviewerAssignment
    class AssignService < ::BaseProjectService
      include Gitlab::InternalEventsTracking

      def initialize(merge_request:, strategy:, current_user:)
        super(project: merge_request.project, current_user: current_user)

        @merge_request = merge_request
        @strategy = strategy
      end

      def execute
        return skipped('Feature not available') unless approvers_feature_available?
        return skipped('Feature disabled') unless auto_assignment_enabled?
        return skipped('MR is draft') if merge_request.draft?
        return skipped('Reviewers already assigned') if merge_request.reviewers.any?

        reviewers_to_assign = strategy.select_reviewers
        return skipped('No eligible reviewers') if reviewers_to_assign.empty?

        reviewers_to_assign, limit_reached = enforce_reviewer_limit(reviewers_to_assign)
        result = assign_reviewers(reviewers_to_assign)
        return result if result.is_a?(ServiceResponse) && result.error?

        assigned_count = merge_request.reset.reviewers.count
        return error('Failed to assign reviewers') if assigned_count == 0

        track_assignment(assigned_count)

        if limit_reached
          return ServiceResponse.success(message: 'Assigned reviewers limit reached',
            payload: { limit_reached: true })
        end

        ServiceResponse.success
      end

      private

      attr_reader :merge_request, :strategy

      def approvers_feature_available?
        project.licensed_feature_available?(:merge_request_approvers)
      end

      def auto_assignment_enabled?
        project.project_setting.reviewer_auto_assignment_enabled?
      end

      def enforce_reviewer_limit(users)
        limit = ::Issuable::MAX_NUMBER_OF_ASSIGNEES_OR_REVIEWERS
        [users.first(limit), users.size > limit]
      end

      def assign_reviewers(users)
        MergeRequests::UpdateReviewersService.new(
          project: project,
          current_user: current_user,
          params: { reviewer_ids: users.map(&:id) }
        ).execute(merge_request)
      rescue ActiveRecord::RecordInvalid => e
        Gitlab::ErrorTracking.track_exception(e, merge_request_id: merge_request.id)
        ServiceResponse.error(message: "Failed to assign reviewers: #{e.message}")
      end

      def track_assignment(assigned_count)
        track_internal_event(
          'auto_assign_reviewers',
          project: project,
          namespace: project.namespace,
          user: merge_request.author,
          additional_properties: {
            label: strategy.strategy_name,
            value: assigned_count
          }
        )
      end

      def error(message)
        ServiceResponse.error(message: message)
      end

      def skipped(message)
        ServiceResponse.success(message: message, payload: { skipped: true })
      end
    end
  end
end
