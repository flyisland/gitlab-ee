# frozen_string_literal: true

module JH
  module GitlabSubscription
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override
    include ::Gitlab::Utils::StrongMemoize

    private

    def team_plan_id
      ::Plan.find_by(name: ::Plan::TEAM)&.id
    end
    strong_memoize_attr :team_plan_id

    def team_plan_not_renewed?
      previous_team_gs = ::GitlabSubscriptions::SubscriptionHistory
                           .where(gitlab_subscription_id: id, hosted_plan_id: team_plan_id).order(:id).last

      previous_team_gs&.start_date == start_date && previous_team_gs&.end_date == end_date
    end

    # Team plan follows the logic of premium plan
    #
    # For premium plan:
    # 1. ultimate-trial-paid-customer => premium(not renewed), do not reset_seat_statistics,
    # 2. ultimate-trial-paid-customer => premium(renewed), reset_seat_statistics
    #
    # For team plan:
    # 1. ultimate-trial-paid-customer => team(not renewed), do not reset_seat_statistics,
    # 2. ultimate-trial-paid-customer => team(renewed), reset_seat_statistics
    #
    # See: https://gitlab.com/gitlab-org/gitlab/-/merge_requests/137243
    override :reset_involves_ultimate_trial_paid_customer_plan?
    def reset_involves_ultimate_trial_paid_customer_plan?
      return false if hosted_plan_id == team_plan_id && team_plan_not_renewed?

      super
    end
  end
end
