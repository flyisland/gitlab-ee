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
            description: 'Continuous deployment applications in the organization.',
            resolver: ::Resolvers::Cd::OrganizationApplicationsResolver,
            experiment: { milestone: '19.1' }

          field :cd_application, ::Types::Cd::ApplicationType,
            null: true,
            description: 'Continuous deployment application in the organization.',
            resolver: ::Resolvers::Cd::OrganizationApplicationResolver,
            experiment: { milestone: '19.2' }

          field :cd_service, ::Types::Cd::ServiceType,
            null: true,
            description: 'Continuous deployment service in the organization.',
            resolver: ::Resolvers::Cd::OrganizationServiceResolver,
            experiment: { milestone: '19.2' }

          field :cd_environments, ::Types::Cd::EnvironmentType.connection_type,
            null: true,
            description: 'Continuous deployment environments in the organization.',
            resolver: ::Resolvers::Cd::OrganizationEnvironmentsResolver,
            experiment: { milestone: '19.1' }

          field :cd_environment, ::Types::Cd::EnvironmentType,
            null: true,
            description: 'Continuous deployment environment in the organization.',
            resolver: ::Resolvers::Cd::OrganizationEnvironmentResolver,
            experiment: { milestone: '19.2' }

          field :cd_environment_tiers, [::Types::Cd::EnvironmentTierEnum],
            null: true,
            description: 'Continuous deployment environment tiers available in the organization.',
            resolver: ::Resolvers::Cd::OrganizationEnvironmentTiersResolver,
            experiment: { milestone: '19.2' }

          field :cd_rollout, ::Types::Cd::RolloutType,
            null: true,
            description: 'Continuous deployment rollout in the organization.',
            resolver: ::Resolvers::Cd::OrganizationRolloutResolver,
            experiment: { milestone: '19.2' }

          field :cd_version_set, ::Types::Cd::VersionSetType,
            null: true,
            description: 'Continuous deployment version set in the organization.',
            resolver: ::Resolvers::Cd::OrganizationVersionSetResolver,
            experiment: { milestone: '19.2' }
        end
      end
    end
  end
end
