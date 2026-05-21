# frozen_string_literal: true

module Types
  module Security
    module Ascp
      # rubocop: disable Graphql/AuthorizeTypes -- Authorization handled by parent SecurityContextType
      class SecurityGuidelineType < BaseObject
        graphql_name 'AscpSecurityGuideline'
        description 'A security guideline for an ASCP component'

        field :id, ::Types::GlobalIDType[::Security::Ascp::SecurityGuideline],
          null: false,
          description: 'ID of the guideline.'

        field :name, GraphQL::Types::String,
          null: false,
          description: 'Policy name.'

        field :operation, GraphQL::Types::String,
          null: false,
          description: 'Security-sensitive operation.'

        field :legitimate_use, GraphQL::Types::String,
          null: true,
          description: 'When the operation is expected and acceptable.'

        field :security_boundary, GraphQL::Types::String,
          null: true,
          description: 'When the operation becomes a security risk.'

        field :business_context, GraphQL::Types::String,
          null: true,
          description: 'How to assess business impact if violated.'

        field :severity_if_violated, Types::Security::Ascp::SeverityEnum,
          null: false,
          description: 'Severity level if the guideline is violated.'
      end
      # rubocop: enable Graphql/AuthorizeTypes
    end
  end
end
