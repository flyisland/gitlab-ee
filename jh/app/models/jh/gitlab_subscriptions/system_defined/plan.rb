# frozen_string_literal: true

module JH
  module GitlabSubscriptions
    module SystemDefined
      module Plan
        extend ActiveSupport::Concern

        TEAM_PLAN = { id: 10_000, name: 'team', title: 'Team' }.freeze

        module ::EE
          module GitlabSubscriptions
            module SystemDefined
              module Plan
                TEAM = ::Plan::TEAM

                %i[PAID_HOSTED_PLANS TIERS PREMIUM_TIER_PLANS EE_ALL_PLANS].each do |name|
                  remove_const(name)
                  const_set(name, ::EE::Plan.const_get(name, false))
                end

                private_constant :EE_ALL_PLANS
              end
            end
          end
        end

        class_methods do
          extend ::Gitlab::Utils::Override

          override :all
          def all
            plans = super

            return plans if plans.any? { |plan| plan.name == TEAM_PLAN[:name] }

            plans + [new(TEAM_PLAN)]
          end

          override :tier_for
          def tier_for(plan_name)
            return TEAM_PLAN[:name] if plan_name == TEAM_PLAN[:name]

            super
          end
        end
      end
    end
  end
end
