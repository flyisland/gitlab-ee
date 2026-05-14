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

          field :work_item_types, ::Types::WorkItems::TypeType.connection_type,
            null: true,
            description: 'Work item types available to the organization.',
            experiment: { milestone: '18.10' },
            resolver: ::Resolvers::WorkItems::TypesResolver
        end
      end
    end
  end
end
