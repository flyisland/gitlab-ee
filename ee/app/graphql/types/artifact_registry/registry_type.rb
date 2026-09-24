# frozen_string_literal: true

module Types
  module ArtifactRegistry
    class RegistryType < BaseObject
      # The flat schema namespace would otherwise derive `Registry`, which is too generic.
      graphql_name 'ArtifactRegistry'
      description 'Artifact Registry an organization is activated for.'

      authorize :read_artifact_registry

      # Reachable only through the organization field, which authorizes against the organization.
      authorize_granular_token skip_reason: :parent_authorizes

      field :slug, GraphQL::Types::String,
        null: true,
        experiment: { milestone: '19.4' },
        description: "Registry slug, Artifact Registry's immutable identifier for the namespace. " \
          '`null` when the status is `unknown`.'

      field :status, GraphQL::Types::String,
        null: false,
        experiment: { milestone: '19.4' },
        description: 'Status Artifact Registry returned, one of `active`, `suspended`, ' \
          '`disabled`, `blocked`, `deleted`, or `purged`, or `unknown` when the mapped ' \
          'namespace did not resolve. Deliberately a string rather than an enum so a ' \
          'status Artifact Registry adds within its API version reaches the response ' \
          'instead of raising.'

      field :created_at, ::Types::TimeType,
        null: true,
        experiment: { milestone: '19.4' },
        description: 'Timestamp the registry was provisioned, presented as the active-since ' \
          'date. `null` when the status is `unknown`.'
    end
  end
end
