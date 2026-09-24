# frozen_string_literal: true

module Types
  module ArtifactRegistry
    class ManifestType < BaseObject
      graphql_name 'ArtifactRegistryManifest'
      description 'Manifest of a container image in an Artifact Registry repository (Docker and OCI).'

      # A manifest reaches the schema as a bare value object with no policy class, so dropping
      # the repository field's `skip_type_authorization` would raise in
      # `DeclarativePolicy.class_for` -- a 500, not a 403. Declared so the type still states it.
      authorize :read_artifact_registry

      include ::ArtifactRegistry::ExposesElementId

      exposes_element_id noun: 'manifest', milestone: '19.4'

      # A manifest owns no group or project to scope a token against.
      authorize_granular_token skip_reason: :parent_authorizes

      field :digest, GraphQL::Types::String,
        null: false,
        experiment: { milestone: '19.4' },
        description: 'Content-addressable digest of the manifest.'

      field :media_type, GraphQL::Types::String,
        null: false,
        experiment: { milestone: '19.4' },
        description: 'Media type of the manifest.'

      field :artifact_type, GraphQL::Types::String,
        null: true,
        experiment: { milestone: '19.4' },
        description: 'Artifact type of the manifest. Null when the manifest declares none.'

      field :subject_digest, GraphQL::Types::String,
        null: true,
        experiment: { milestone: '19.4' },
        description: 'Digest of the subject manifest a referrer refers to. Null for a manifest ' \
          'that is not a referrer, and always null on this connection until the ' \
          'referrer-inclusion argument lands: the read leaves Artifact Registry on its ' \
          'default, which excludes referrers.'

      # BigInt rather than Int, matching the repository counters: a size above two gigabytes
      # overflows a GraphQL Int.
      field :size, GraphQL::Types::BigInt,
        null: false,
        experiment: { milestone: '19.4' },
        description: 'Size of the manifest, in bytes. For a hosted repository, the push-time ' \
          'tree total, where an index total already contains its platform children and so does ' \
          'not sum across sibling rows. For a remote repository, the cached manifest\'s own ' \
          'payload bytes.'

      field :created_at, ::Types::TimeType,
        null: true,
        experiment: { milestone: '19.4' },
        description: 'Time the manifest was pushed. Null if the timestamp is absent or unparseable.'
    end
  end
end
