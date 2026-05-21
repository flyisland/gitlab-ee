# frozen_string_literal: true

module Types
  module Ai
    module Catalog
      class McpServerType < ::Types::BaseObject
        graphql_name 'AiCatalogMcpServer'
        description 'An MCP (Model Context Protocol) server'
        authorize :read_ai_catalog_mcp_server

        field :id,
          GraphQL::Types::ID,
          null: false,
          description: 'ID of the MCP server.'

        field :name,
          GraphQL::Types::String,
          null: false,
          description: 'Name of the MCP server.'

        field :description,
          GraphQL::Types::String,
          null: true,
          description: 'Description of the MCP server.'

        field :url,
          GraphQL::Types::String,
          null: false,
          description: 'URL of the MCP server.'

        field :homepage_url,
          GraphQL::Types::String,
          null: true,
          description: 'Homepage URL of the MCP server.'

        field :transport,
          Types::Ai::Catalog::McpServerTransportEnum,
          null: false,
          description: 'Transport type for the MCP server.'

        field :auth_type,
          Types::Ai::Catalog::McpServerAuthTypeEnum,
          null: false,
          description: 'Authentication type for the MCP server.'

        field :oauth_client_id,
          GraphQL::Types::String,
          null: true,
          description: 'OAuth client ID for the MCP server.'

        field :created_at,
          Types::TimeType,
          null: false,
          description: 'Timestamp when the MCP server was created.'

        field :updated_at,
          Types::TimeType,
          null: false,
          description: 'Timestamp when the MCP server was last updated.'

        field :organization,
          Types::Organizations::OrganizationType,
          null: false,
          description: 'Organization that owns the MCP server.'

        field :current_user_connected,
          GraphQL::Types::Boolean,
          null: false,
          description: 'Whether the current user has connected to the MCP server.'

        def current_user_connected
          object.connected_by_user?(context[:current_user])
        end
      end
    end
  end
end
