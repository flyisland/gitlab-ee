# frozen_string_literal: true

module Resolvers
  module Cd
    class VersionSetsResolver < BaseResolver
      include LooksAhead

      type ::Types::Cd::VersionSetType.connection_type, null: true

      alias_method :application, :object

      def resolve_with_lookahead(**)
        return unless Feature.enabled?(:ai_native_deploy, current_user)

        apply_lookahead(application.version_sets)
      end

      private

      def preloads
        {
          version_set_entries: [:version_set_entries],
          rollouts: [:rollouts]
        }
      end
    end
  end
end
