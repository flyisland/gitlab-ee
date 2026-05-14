# frozen_string_literal: true

module DuoChatPanel
  class TrialExpiredComponent < ViewComponent::Base
    include DuoChatPanel::DuoChatHelper
    include ::Gitlab::Utils::StrongMemoize

    def initialize(source:, user:)
      @source = source
      @user = user
    end

    private

    attr_reader :source, :user

    def data
      can_buy = saas? && !!(root_namespace && Ability.allowed?(user, :edit_billing, root_namespace))
      buy_path = can_buy ? trial_expired_buy_path : nil

      {
        is_trial_expired: 'true',
        buy_addon_path: buy_path,
        can_buy_addon: can_buy.to_s,
        can_start_trial: 'false',
        auto_expand: should_auto_expand_panel?(user, 'duo_panel_empty_state_auto_expanded').to_s
      }.compact
    end

    def root_namespace
      source&.root_ancestor
    end
    strong_memoize_attr :root_namespace

    def trial_expired_buy_path
      plans_data = ::GitlabSubscriptions::FetchSubscriptionPlansService.new(
        plan: root_namespace.plan_name_for_upgrading,
        namespace_id: root_namespace.id
      ).execute

      premium_plan = find_plan(plans_data, ::Plan::PREMIUM) if plans_data
      ::GitlabSubscriptions::PurchaseUrlBuilder.new(plan_id: premium_plan&.id, namespace: root_namespace).build
    end
    strong_memoize_attr :trial_expired_buy_path

    def find_plan(plans_data, plan_code)
      plans_data.find { |plan| plan.code == plan_code }
    end
  end
end
