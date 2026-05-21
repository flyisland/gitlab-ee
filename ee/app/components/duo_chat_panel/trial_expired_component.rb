# frozen_string_literal: true

module DuoChatPanel
  class TrialExpiredComponent < ViewComponent::Base
    include DuoChatPanel::DuoChatHelper
    include DuoChatPanel::PanelAutoExpand

    def initialize(source:, user:)
      @user = user
      @strategy = saas? ? GitlabComStrategy.new(source, user) : SelfManagedStrategy.new(user)
    end

    private

    attr_reader :user, :strategy

    def data
      {
        is_trial_expired: 'true',
        buy_addon_path: (strategy.expired_buy_path if strategy.can_buy_addon?),
        can_buy_addon: strategy.can_buy_addon?.to_s,
        can_start_trial: 'false',
        auto_expand: auto_expanded?(user).to_s
      }.compact
    end

    def auto_expanded?(user)
      return false unless user

      # This panel previously had its own `duo_panel_empty_state_auto_expanded` callout. It now
      # relies on the primary `duo_panel_auto_expanded` callout, but we still want to respect cases
      # where users had dismissed the legacy panel, so we gate the auto-expand behavior behind the
      # `duo_panel_empty_state_auto_expanded` callout.
      return false if user.dismissed_callout?(feature_name: 'duo_panel_empty_state_auto_expanded')

      should_auto_expand_panel?(user, 'duo_panel_auto_expanded')
    end

    class GitlabComStrategy
      def initialize(source, user)
        @source = source
        @user = user
      end

      def can_buy_addon?
        root_namespace.present? && Ability.allowed?(@user, :edit_billing, root_namespace)
      end

      def expired_buy_path
        plans_data = ::GitlabSubscriptions::FetchSubscriptionPlansService.new(
          plan: root_namespace.plan_name_for_upgrading,
          namespace_id: root_namespace.id
        ).execute

        premium_plan = find_plan(plans_data, ::Plan::PREMIUM) if plans_data
        ::GitlabSubscriptions::PurchaseUrlBuilder.new(plan_id: premium_plan&.id, namespace: root_namespace).build
      end

      private

      def root_namespace
        @source&.root_ancestor
      end

      def find_plan(plans_data, plan_code)
        plans_data.find { |plan| plan.code == plan_code }
      end
    end

    class SelfManagedStrategy
      def initialize(user)
        @user = user
      end

      def can_buy_addon?
        @user.can_admin_all_resources?
      end

      def expired_buy_path
        ::Gitlab::Routing.url_helpers.subscription_portal_url
      end
    end
  end
end
