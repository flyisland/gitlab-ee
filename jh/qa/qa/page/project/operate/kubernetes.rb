# frozen_string_literal: true

module QA
  module Page
    module Project
      module Operate
        class Kubernetes < QA::Page::Base
          view 'app/assets/javascripts/clusters_list/components/agent_table.vue' do
            element 'cluster-agent-list-table'
            element 'cluster-agent-connection-status'
          end

          def has_agent?(agent_name)
            within_element('cluster-agent-list-table') do
              has_text?(agent_name)
            end
          end

          def has_agent_connected?
            has_element?('cluster-agent-connection-status', text: "Connected")
          end
        end
      end
    end
  end
end
