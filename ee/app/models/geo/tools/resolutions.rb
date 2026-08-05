# frozen_string_literal: true

module Geo
  module Tools
    # SPIKE (gitlab-org/gitlab#602803): maps a catalog entry's resolve_strategy to the
    # resolution object that knows how to detect and fix it. Registering a new strategy is a
    # one-line addition to STRATEGIES, so this stays a lookup rather than a growing case.
    module Resolutions
      UnknownStrategyError = Class.new(StandardError)

      STRATEGIES = {
        'resync' => Resync,
        'remove_duplicate_registries' => RemoveDuplicateRegistries,
        'delete_orphaned_uploads' => DeleteOrphanedUploads
      }.freeze

      def self.for(error_type)
        strategy = error_type.resolve_strategy
        resolution_class = STRATEGIES.fetch(strategy) do
          raise UnknownStrategyError, "Unknown resolve strategy: #{strategy}"
        end

        resolution_class.new(error_type)
      end
    end
  end
end
