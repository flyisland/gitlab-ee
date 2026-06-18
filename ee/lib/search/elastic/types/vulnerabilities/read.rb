# frozen_string_literal: true

module Search
  module Elastic
    module Types
      module Vulnerabilities
        class Read < Vulnerability
          class << self
            def index_name
              Search::Elastic::References::Vulnerabilities::Read.index
            end

            def base_mappings
              super.merge({
                is_default: { type: 'boolean' }
              })
            end
          end
        end
      end
    end
  end
end
