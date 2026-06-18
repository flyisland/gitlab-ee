# frozen_string_literal: true

module Ai
  module ActiveContext
    class << self
      def paused?
        return false unless ::ActiveContext.indexing?

        Gitlab::CurrentSettings.active_context_indexing_paused?
      end

      def semantic_search_available?
        License.ai_features_available? &&
          ::Gitlab::CurrentSettings.duo_features_enabled?
      end
    end
  end
end
