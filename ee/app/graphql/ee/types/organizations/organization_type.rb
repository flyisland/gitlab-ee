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

          field :cd_applications, ::Types::Cd::ApplicationType.connection_type,
            null: true,
            description: 'Continuous deployment applications in the organization, including those attached ' \
              'to groups belonging to the organization.',
            resolver: ::Resolvers::Cd::OrganizationApplicationsResolver,
            experiment: { milestone: '19.1' }

          field :cd_environments, ::Types::Cd::EnvironmentType.connection_type,
            null: true,
            description: 'Continuous deployment environments in the organization, including those attached ' \
              'to groups belonging to the organization.',
            resolver: ::Resolvers::Cd::OrganizationEnvironmentsResolver,
            experiment: { milestone: '19.1' }
        end
      end
    end
  end
end
