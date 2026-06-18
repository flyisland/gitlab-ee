# frozen_string_literal: true

module Mutations
  module Cd
    module Environments
      class Create < ::Mutations::BaseMutation
        graphql_name 'CdEnvironmentCreate'
        description 'Creates a continuous deployment environment in a group or organization.'

        include Mutations::ResolvesGroup

        authorize :create_cd_environment
        authorize_granular_token permissions: :create_cd_environment,
          boundaries: [
            { boundary_argument: :group_path, boundary_type: :group },
            { boundary: :instance, boundary_type: :instance }
          ]

        argument :group_path, GraphQL::Types::ID,
          required: false,
          description: 'Full path of the group to create the environment in. ' \
            'Exactly one of `groupPath` or `organizationId` must be provided.'

        argument :organization_id, ::Types::GlobalIDType[::Organizations::Organization],
          required: false,
          description: 'Global ID of the organization to create the environment in. ' \
            'Exactly one of `groupPath` or `organizationId` must be provided.'

        argument :name, GraphQL::Types::String,
          required: true,
          description: copy_field_description(::Types::Cd::EnvironmentType, :name)

        argument :description, GraphQL::Types::String,
          required: false,
          description: copy_field_description(::Types::Cd::EnvironmentType, :description)

        argument :cluster_agent_id, ::Types::GlobalIDType[::Clusters::Agent],
          required: true,
          description: 'Global ID of the cluster agent the environment targets.'

        field :environment, ::Types::Cd::EnvironmentType,
          null: true,
          description: 'Environment created by the mutation.'

        validates exactly_one_of: [:group_path, :organization_id]

        def ready?(**args)
          raise_resource_not_available_error! unless Feature.enabled?(:ai_native_deploy, current_user)

          super
        end

        def resolve(args)
          parent = authorized_find!(
            group_path: args.delete(:group_path),
            organization_id: args.delete(:organization_id)
          )

          args[:cluster_agent] = authorized_cluster_agent!(args.delete(:cluster_agent_id))

          response = ::Cd::Environments::CreateService
            .new(parent: parent, current_user: current_user, params: args)
            .execute

          {
            environment: response.success? ? response.payload[:environment] : nil,
            errors: response.errors
          }
        end

        private

        def find_object(group_path:, organization_id:)
          if organization_id.present?
            ::GitlabSchema.object_from_id(organization_id, expected_type: ::Organizations::Organization).sync
          else
            resolve_group(full_path: group_path)
          end
        end

        def authorized_cluster_agent!(cluster_agent_gid)
          cluster_agent = ::GitlabSchema.object_from_id(cluster_agent_gid, expected_type: ::Clusters::Agent).sync

          raise_resource_not_available_error! unless current_user.can?(:read_cluster_agent, cluster_agent)

          cluster_agent
        end
      end
    end
  end
end
