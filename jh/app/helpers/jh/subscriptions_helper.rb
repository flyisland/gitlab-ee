# frozen_string_literal: true

module JH
  module SubscriptionsHelper
    extend ::Gitlab::Utils::Override

    override :subscription_available_plans
    def subscription_available_plans
      filtered_data = super

      team_plan = filtered_data.find { |plan| plan[:code] == 'team' }
      filtered_data = filtered_data.reject { |plan| plan[:code] == 'team' || plan[:code] == 'free' }
      filtered_data.unshift(team_plan) if team_plan

      filtered_data
    end
  end
end
