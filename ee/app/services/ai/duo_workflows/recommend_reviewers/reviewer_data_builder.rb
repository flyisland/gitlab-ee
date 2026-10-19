# frozen_string_literal: true

module Ai
  module DuoWorkflows
    module RecommendReviewers
      class ReviewerDataBuilder
        include Gitlab::Utils::StrongMemoize

        # The rules share one approver budget so the reviewer data stays under the
        # 128 KiB limit of the CI variable. The per-rule floor means that more than
        # 40 rules can still go over MAX_TOTAL_APPROVERS.
        MAX_APPROVERS_PER_RULE = 50
        MIN_APPROVERS_PER_RULE = 10
        MAX_TOTAL_APPROVERS = 400

        def self.build(merge_request)
          new(merge_request).build
        end

        def initialize(merge_request)
          @merge_request = merge_request
        end

        def build
          {
            "current_reviewers" => current_reviewers_data,
            "approval_rules" => approval_rules_data
          }
        end

        private

        attr_reader :merge_request

        def current_reviewers_data
          merge_request.reviewers.map { |r| { "id" => r.id } }
        end

        def approval_rules_data
          grouped_approval_rules.map do |rule|
            {
              "id" => rule.id,
              "type" => rule.approval_rule.is_a?(ApprovalProjectRule) ? "project_rule" : "merge_request_rule",
              "name" => rule.name,
              "section" => rule.section,
              "approvals_required" => rule.approvals_required,
              "eligible_approvers" => eligible_approvers_for(rule)
            }
          end
        end

        def eligible_approvers_for(rule)
          approvers = approvers_for(rule).filter_map { |u| preloaded_user_data[u.id] }
          return approvers if approvers.size <= approvers_limit

          approvers
            .sort_by { |u| [u['busy'] ? 1 : 0, u['pending_reviews']] }
            .first(approvers_limit)
        end

        def approvers_limit
          (MAX_TOTAL_APPROVERS / [grouped_approval_rules.size, 1].max)
            .clamp(MIN_APPROVERS_PER_RULE, MAX_APPROVERS_PER_RULE)
        end
        strong_memoize_attr :approvers_limit

        # `any_approver` rules ("All Members") store no approvers, so left
        # unexpanded the flow gets zero candidates and assigns nobody.
        # https://gitlab.com/gitlab-org/gitlab/-/issues/604144
        def approvers_for(rule)
          return any_approver_candidates if rule.any_approver?

          rule.approvers
        end

        def any_approver_candidates
          merge_request.approval_state.any_approver_candidates(limit: approvers_limit).to_a
        end
        strong_memoize_attr :any_approver_candidates

        def unique_approvers
          grouped_approval_rules.flat_map { |rule| approvers_for(rule) }.uniq(&:id)
        end
        strong_memoize_attr :unique_approvers

        def preloaded_user_data
          ActiveRecord::Associations::Preloader.new(
            records: unique_approvers,
            associations: [:status, :user_preference]
          ).call

          unique_approvers.to_h { |user| [user.id, serialize_user(user)] }
        end
        strong_memoize_attr :preloaded_user_data

        def serialize_user(user)
          {
            "id" => user.id,
            "busy" => user.status&.busy? == true,
            "status_emoji" => user.status&.emoji,
            "status_message" => user.status&.message,
            "pending_reviews" => user.review_requested_open_merge_requests_count,
            "local_time" => user_local_time(user),
            "last_activity_on" => user.last_activity_on&.iso8601
          }.compact
        end

        def user_local_time(user)
          tz_name = user.user_preference&.timezone
          return unless tz_name.present?

          zone = ActiveSupport::TimeZone[tz_name]
          return unless zone

          Time.current.in_time_zone(zone).strftime('%H:%M')
        end

        # Grouped so that code owner rules sharing a section and an approver set
        # collapse into one. Ungrouped, a merge request that matches many
        # CODEOWNERS patterns repeats the same approvers once per pattern.
        def grouped_approval_rules
          merge_request.approval_state.grouped_approval_rules.select do |rule|
            rule.approvals_required > 0 || rule.regular? || rule.code_owner?
          end
        end
        strong_memoize_attr :grouped_approval_rules
      end
    end
  end
end
