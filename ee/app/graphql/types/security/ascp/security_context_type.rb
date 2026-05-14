# frozen_string_literal: true

module Types
  module Security
    module Ascp
      # rubocop: disable Graphql/AuthorizeTypes -- Authorization handled by parent resolver
      class SecurityContextType < BaseObject
        graphql_name 'AscpSecurityContext'
        description 'Security context for an ASCP component'

        field :id, ::Types::GlobalIDType[::Security::Ascp::SecurityContext],
          null: false,
          description: 'ID of the security context.'

        field :summary, GraphQL::Types::String,
          null: true,
          description: 'High-level threat model summary.'

        field :authentication_model, GraphQL::Types::String,
          null: true,
          description: 'How users authenticate to the component.'

        field :authorization_model, GraphQL::Types::String,
          null: true,
          description: 'How access is controlled for the component.'

        field :data_sensitivity, GraphQL::Types::String,
          null: true,
          description: 'Types of sensitive data handled by the component.'

        field :scan, Types::Security::Ascp::ScanType,
          null: false,
          description: 'Scan when the security context was generated.'

        field :security_guidelines, Types::Security::Ascp::SecurityGuidelineType.connection_type,
          null: false,
          description: 'Security guidelines for the context.',
          method: :guidelines

        def scan
          ::Gitlab::Graphql::Loaders::BatchModelLoader.new(::Security::Ascp::Scan, object.scan_id).find
        end
      end
      # rubocop: enable Graphql/AuthorizeTypes
    end
  end
end
