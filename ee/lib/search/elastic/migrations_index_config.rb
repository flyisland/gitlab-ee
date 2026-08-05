# frozen_string_literal: true

module Search
  module Elastic
    class MigrationsIndexConfig
      class << self
        def alias_name
          Search::Elastic::Helper.default.migrations_alias_name
        end

        def mappings
          {
            properties: {
              completed: { type: 'boolean' },
              state: { type: 'object' },
              started_at: { type: 'date' },
              completed_at: { type: 'date' },
              name: { type: 'keyword' }
            }
          }
        end

        def settings
          { number_of_shards: 1 }
        end
      end
    end
  end
end
