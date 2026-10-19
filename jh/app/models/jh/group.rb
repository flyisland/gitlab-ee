# frozen_string_literal: true

module JH
  # User JH mixin
  #
  # This module is intended to encapsulate JH-specific model logic
  # and be prepended in the  model

  module Group
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    prepended do
      include ContentValidateable
      validates :name, :description, content_validation: true, if: :should_validate_content?
    end

    override :actual_size_limit
    def actual_size_limit
      return super unless ::Gitlab.jh? && ::Gitlab.com?
      return super if actual_limits.repository_size.nil?

      actual_limits.repository_size
    end

    override :block_seat_overages?
    def block_seat_overages?
      return super unless ::Feature.enabled?(:jh_only_block_seat_for_team_plan)

      super && actual_plan_without_generate_subscription.name == ::Plan::TEAM
    end
  end
end
