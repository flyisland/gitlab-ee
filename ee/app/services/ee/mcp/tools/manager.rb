# frozen_string_literal: true

module EE
  module Mcp
    module Tools
      module Manager
        extend ::Gitlab::Utils::Override

        # Registry of all EE custom tools mapped to their service classes.
        EE_CUSTOM_TOOLS = {}.freeze
        EE_GRAPHQL_TOOLS = {}.freeze

        private

        override :custom_tools
        def custom_tools
          @custom_tools ||= super.merge(EE_CUSTOM_TOOLS).freeze
        end

        override :graphql_tools
        def graphql_tools
          @graphql_tools ||= super.merge(EE_GRAPHQL_TOOLS).freeze
        end
      end
    end
  end
end
