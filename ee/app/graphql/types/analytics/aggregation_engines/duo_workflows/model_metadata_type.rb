# frozen_string_literal: true

module Types
  module Analytics
    module AggregationEngines
      module DuoWorkflows
        # rubocop: disable Graphql/AuthorizeTypes -- metadata for aggregated
        # rows; the mounted engine field authorizes the request.
        class ModelMetadataType < ::Types::BaseObject
          graphql_name 'DuoWorkflowsModelMetadata'
          description 'Catalog metadata for a model used by GitLab Duo Agent Platform flows'

          authorize_granular_token skip_reason: :parent_authorizes

          field :name, GraphQL::Types::String, null: true,
            description: 'Display name from the model catalog, or the raw value when not in the catalog. ' \
              '`null` for flows with no model attribution.'

          field :provider, GraphQL::Types::String, null: true,
            description: 'Model provider when the catalog identifies it unambiguously.'

          field :hosting, Types::Analytics::AggregationEngines::DuoWorkflows::ModelHostingEnum, null: true,
            description: 'Where the model is hosted. `null` for flows with no model attribution.'

          field :is_default, GraphQL::Types::Boolean, null: false,
            description: 'Whether the model is a configured default for GitLab Duo Agent Platform features.'
        end
        # rubocop: enable Graphql/AuthorizeTypes
      end
    end
  end
end
