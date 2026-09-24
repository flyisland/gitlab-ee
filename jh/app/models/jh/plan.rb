# frozen_string_literal: true

module JH
  module Plan
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    prepended do
      enum :plan_name_uid, plan_name_uids, instance_methods: false, scopes: false
    end

    module ::EE
      module Plan
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override

        TEAM = 'team'

        temp_paid_hosted_plans = PAID_HOSTED_PLANS.dup
        remove_const :PAID_HOSTED_PLANS
        PAID_HOSTED_PLANS = (temp_paid_hosted_plans + [TEAM]).freeze

        temp_tiers = TIERS.dup
        remove_const :TIERS
        TIERS = temp_tiers.insert(temp_tiers.index(PREMIUM), TEAM).freeze

        remove_const :PREMIUM_TIER_PLANS
        PREMIUM_TIER_PLANS = (PAID_HOSTED_PLANS - ULTIMATE_TIER_PLANS - [TEAM]).freeze

        temp_ee_all_plans = EE_ALL_PLANS.dup
        remove_const :EE_ALL_PLANS
        EE_ALL_PLANS = (temp_ee_all_plans + [TEAM]).freeze
      end
    end

    class_methods do
      extend ::Gitlab::Utils::Override

      override :plan_name_uids
      def plan_name_uids
        super.merge('team' => 10000)
      end

      override :tier_for
      def tier_for(plan_name)
        return ::Plan::TEAM if plan_name == ::Plan::TEAM

        super
      end
    end
  end
end
