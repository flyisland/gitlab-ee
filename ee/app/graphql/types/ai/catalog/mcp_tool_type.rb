# frozen_string_literal: true

module Types
  module Ai
    module Catalog
      # rubocop: disable Graphql/AuthorizeTypes -- Always public
      class McpToolType < ::Types::BaseObject
        graphql_name 'AiCatalogMcpTool'
        description 'An MCP tool dynamically discovered from the GitLab MCP server.'

        field :description, String, null: true, description: 'Description of the MCP tool.'
        field :name, GraphQL::Types::ID, null: false, description: 'Machine-readable name of the MCP tool.'
        field :title, String, null: false, description: 'Human-readable title of the MCP tool.'
      end
      # rubocop: enable Graphql/AuthorizeTypes
    end
  end
end
