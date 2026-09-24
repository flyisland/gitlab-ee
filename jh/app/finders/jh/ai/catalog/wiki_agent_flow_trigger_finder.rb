# frozen_string_literal: true

module JH
  module Ai
    module Catalog
      class WikiAgentFlowTriggerFinder
        AGENT_NAME = 'Wiki Agent'

        def initialize(project)
          @project = project
        end

        def execute
          item_consumer = wiki_agent&.consumers&.for_projects(project)&.first

          project.ai_flow_triggers
            .active
            .by_item_consumer_ids(item_consumer ? item_consumer.id : [])
            .ordered_by_id
        end

        private

        attr_reader :project

        def wiki_agent
          ::Ai::Catalog::Item
            .not_deleted
            .with_item_type(:third_party_flow)
            .for_verification_level(:gitlab_maintained)
            .search(AGENT_NAME)
            .detect { |item| item.name == AGENT_NAME }
        end
      end
    end
  end
end
