# frozen_string_literal: true

module Types
  module Analytics
    module Orbit
      class ItemCountDomainType < BaseObject # rubocop:disable Graphql/AuthorizeTypes -- parent field authorizes
        graphql_name 'OrbitItemCountDomain'
        description 'Number of indexed items in one Orbit domain.'

        authorize_granular_token skip_reason: :parent_authorizes

        field :entities, [ItemCountEntityType], null: true,
          description: 'Number of indexed items of each entity in the domain.'
        field :name, GraphQL::Types::String, null: false,
          description: 'Name of the domain.'
      end
    end
  end
end
