# frozen_string_literal: true

module Types
  module Cd
    class ArtifactSourceInputType < ::Types::BaseInputObject
      graphql_name 'CdArtifactSourceInput'
      description 'Attributes for a continuous deployment artifact source.'

      argument :name, GraphQL::Types::String,
        required: true,
        description: copy_field_description(::Types::Cd::ArtifactSourceType, :name)

      argument :source_ref, GraphQL::Types::String,
        required: true,
        description: copy_field_description(::Types::Cd::ArtifactSourceType, :source_ref)
    end
  end
end
