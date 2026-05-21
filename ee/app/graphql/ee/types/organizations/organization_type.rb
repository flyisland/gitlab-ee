# frozen_string_literal: true

module EE
  module Types
    module Organizations
      module OrganizationType
        extend ActiveSupport::Concern

        prepended do
          field :workspaces_cluster_agents,
            ::Types::Clusters::AgentType.connection_type,
            extras: [:lookahead],
            null: true,
            description: 'Cluster agents in the organization with workspaces capabilities',
            experiment: { milestone: '17.10' },
            resolver: ::Resolvers::RemoteDevelopment::Organization::ClusterAgentsResolver

          field :work_item_settings,
            ::Types::WorkItems::SettingsType,
            null: true,
            resolver: ::Resolvers::WorkItems::SettingsResolver,
            experiment: { milestone: '19.0' },
            description: 'Work item settings for the organization.'
        end
      end
    end
  end
end
