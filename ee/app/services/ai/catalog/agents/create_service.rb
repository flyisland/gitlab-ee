# frozen_string_literal: true

module Ai
  module Catalog
    module Agents
      class CreateService < Ai::Catalog::Items::BaseCreateService
        extend Gitlab::Utils::Override

        private

        override :item_type
        def item_type
          Ai::Catalog::Item::AGENT_TYPE
        end

        override :schema_version
        def schema_version
          Ai::Catalog::ItemVersion::AGENT_SCHEMA_VERSION
        end

        override :definition
        def definition
          {
            tools: Array(params[:tools]).map(&:id),
            mcp_tools: Array(params[:mcp_tools]),
            mcp_servers: Array(params[:mcp_servers]),
            system_prompt: params[:system_prompt],
            user_prompt: params[:user_prompt] || ""
          }
        end
      end
    end
  end
end
