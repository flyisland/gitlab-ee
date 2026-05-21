# frozen_string_literal: true

module Search
  module Zoekt
    module OffsetPagination
      MIN_VERSION = '1.9.0'

      def self.active?
        ::Feature.enabled?(:zoekt_offset_pagination) && # rubocop:disable Gitlab/FeatureFlagWithoutActor -- global rollout, no meaningful per-actor targeting
          ::Search::Zoekt::Node.all_at_least_version?(MIN_VERSION)
      end
    end
  end
end
