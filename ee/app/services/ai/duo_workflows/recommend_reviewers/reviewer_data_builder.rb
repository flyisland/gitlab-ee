# frozen_string_literal: true

module Ai
  module DuoWorkflows
    module RecommendReviewers
      class ReviewerDataBuilder
        include Gitlab::Utils::StrongMemoize

        # Cap the number of eligible approvers per rule to avoid blowing up the
        # LLM prompt for projects with very large CODEOWNERS groups. The LLM
        # only needs a handful of candidates to choose from which we'll provide
        # from the sorted list of approvers based on their availability.
        MAX_APPROVERS_PER_RULE = 100

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
          merge_request.reviewers.map { |r| { "id" => r.id, "username" => r.username } }
        end

        def approval_rules_data
          wrapped_approval_rules.map do |rule|
            {
              "name" => rule.name,
              "section" => rule.section,
              "approvals_required" => rule.approvals_required,
              "eligible_approvers" => eligible_approvers_for(rule)
            }
          end
        end

        def eligible_approvers_for(rule)
          approvers = rule.approvers.filter_map { |u| preloaded_user_data[u.id] }
          return approvers if approvers.size <= MAX_APPROVERS_PER_RULE

          approvers
            .sort_by { |u| [u['busy'] ? 1 : 0, u['pending_reviews']] }
            .first(MAX_APPROVERS_PER_RULE)
        end

        def unique_approvers
          wrapped_approval_rules.flat_map(&:approvers).uniq(&:id)
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
            "username" => user.username,
            "busy" => user.status&.busy? == true,
            "status_emoji" => user.status&.emoji,
            "status_message" => user.status&.message,
            "pending_reviews" => user.review_requested_open_merge_requests_count,
            "local_time" => user_local_time(user),
            "last_activity_on" => user.last_activity_on&.iso8601
          }
        end

        def user_local_time(user)
          tz_name = user.user_preference&.timezone
          return unless tz_name.present?

          zone = ActiveSupport::TimeZone[tz_name]
          return unless zone

          Time.current.in_time_zone(zone).strftime('%H:%M')
        end

        def wrapped_approval_rules
          merge_request.approval_state.wrapped_approval_rules.select { |rule| rule.approvals_required > 0 }
        end
        strong_memoize_attr :wrapped_approval_rules
      end
    end
  end
end
