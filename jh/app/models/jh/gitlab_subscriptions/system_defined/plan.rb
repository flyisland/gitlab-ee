# frozen_string_literal: true

module JH
  module GitlabSubscriptions
    module SystemDefined
      module Plan
        extend ActiveSupport::Concern

        TEAM_PLAN = { id: 10_000, name: 'team', title: 'Team' }.freeze

        class_methods do
          extend ::Gitlab::Utils::Override

          override :all
          def all
            plans = super

            return plans if plans.any? { |plan| plan.name == TEAM_PLAN[:name] }

            plans + [new(TEAM_PLAN)]
          end
        end
      end
    end
  end
end
