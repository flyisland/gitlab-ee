# frozen_string_literal: true

module Approvals # rubocop:disable Gitlab/BoundedContexts -- existing module for approvals models
  # A shared context object that holds pre-computed data needed for approval rule evaluation.
  # This avoids redundant expensive computations when evaluating multiple approval rules
  # for the same merge request.
  class Context
    include ::Gitlab::Utils::StrongMemoize

    attr_reader :merge_request

    def initialize(merge_request)
      @merge_request = merge_request
    end

    def overall_approver_ids
      current_approvals = merge_request.approvals

      if current_approvals.is_a?(ActiveRecord::Relation) && !current_approvals.loaded?
        current_approvals.distinct.pluck(:user_id).to_set # rubocop:disable Database/AvoidUsingPluckWithoutLimit -- bounded by approvals per MR
      else
        current_approvals.map(&:user_id).to_set
      end
    end
    strong_memoize_attr :overall_approver_ids

    def optimization_enabled?
      Feature.enabled?(:overall_approver_ids_optimization, merge_request.target_project)
    end
    strong_memoize_attr :optimization_enabled?
  end
end
