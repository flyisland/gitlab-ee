# frozen_string_literal: true

module JH
  module Gitlab
    module Ai
      module Catalog
        module ThirdPartyFlows
          module Seeder
            extend ::Gitlab::Utils::Override

            attr_reader :organization

            def seed_missing_agents!
              return unless organization

              existing_agent_names = gitlab_managed_agents.map(&:name)
              return if existing_agent_names.empty?

              missing_agents = agents.reject { |agent| existing_agent_names.include?(agent[:name]) }
              return if missing_agents.empty?

              ::Ai::Catalog::Item.transaction do
                missing_agents.each { |agent| seed_agent(agent) }
              end
            end

            override :agents
            def agents
              super + [
                {
                  name: 'Wiki Agent',
                  description: 'GitLab-managed external agent for generating and updating wikis.',
                  definition: <<~YAML
                  injectGatewayToken: true
                  image: registry.jihulab.com/gitlab-cn/modelops/wiki-agent-image:latest
                  commands:
                    - . /opt/wiki-agent/agent_session_helper.sh
                    - /opt/wiki-agent/run.sh
                  YAML
                }
              ]
            end

            private

            def gitlab_managed_agents
              ::Ai::Catalog::Item
                .in_organization(organization)
                .for_project(nil)
                .not_deleted
                .public_only
                .with_item_type(::Ai::Catalog::Item::THIRD_PARTY_FLOW_TYPE)
                .for_verification_level(:gitlab_maintained)
            end
          end
        end
      end
    end
  end
end
