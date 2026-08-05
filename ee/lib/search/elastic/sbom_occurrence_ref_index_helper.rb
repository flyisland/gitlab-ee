# frozen_string_literal: true

module Search
  module Elastic
    module SbomOccurrenceRefIndexHelper
      class << self
        def indexing_allowed?
          ::Gitlab::CurrentSettings.elasticsearch_indexing?
        end
      end
    end
  end
end
