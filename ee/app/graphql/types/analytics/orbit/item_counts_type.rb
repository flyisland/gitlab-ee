# frozen_string_literal: true

module Types
  module Analytics
    module Orbit
      class ItemCountsType < BaseObject # rubocop:disable Graphql/AuthorizeTypes -- parent field authorizes
        graphql_name 'OrbitItemCounts'
        description 'Number of indexed items of a group or project in Orbit.'

        authorize_granular_token skip_reason: :parent_authorizes

        field :domains, [ItemCountDomainType], null: true,
          description: 'Number of indexed items in each domain.'
      end
    end
  end
end
