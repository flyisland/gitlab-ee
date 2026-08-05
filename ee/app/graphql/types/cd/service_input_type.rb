# frozen_string_literal: true

module Types
  module Cd
    class ServiceInputType < ::Types::BaseInputObject
      graphql_name 'CdServiceInput'
      description 'Attributes for a continuous deployment service.'

      argument :name, GraphQL::Types::String,
        required: true,
        description: copy_field_description(::Types::Cd::ServiceType, :name)

      argument :description, GraphQL::Types::String,
        required: false,
        description: copy_field_description(::Types::Cd::ServiceType, :description)
    end
  end
end
