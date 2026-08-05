# frozen_string_literal: true

module Resolvers
  module Cd
    class RolloutsResolver < BaseResolver
      include LooksAhead

      max_page_size 20

      type ::Types::Cd::RolloutType.connection_type, null: true

      alias_method :application, :object

      def resolve_with_lookahead(**)
        return unless Feature.enabled?(:ai_native_deploy, current_user)

        apply_lookahead(application.rollouts)
      end

      private

      def preloads
        {
          rollout_environments: [:rollout_environments],
          rollout_transitions: [:rollout_transitions]
        }
      end
    end
  end
end
