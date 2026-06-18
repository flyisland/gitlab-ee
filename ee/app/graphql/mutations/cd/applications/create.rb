# frozen_string_literal: true

module Mutations
  module Cd
    module Applications
      class Create < ::Mutations::BaseMutation
        graphql_name 'CdApplicationCreate'
        description 'Creates a continuous deployment application in a group or organization.'

        include Mutations::ResolvesGroup

        authorize :create_cd_application
        authorize_granular_token permissions: :create_cd_application,
          boundaries: [
            { boundary_argument: :group_path, boundary_type: :group },
            { boundary: :instance, boundary_type: :instance }
          ]

        argument :group_path, GraphQL::Types::ID,
          required: false,
          description: 'Full path of the group to create the application in. ' \
            'Exactly one of `groupPath` or `organizationId` must be provided.'

        argument :organization_id, ::Types::GlobalIDType[::Organizations::Organization],
          required: false,
          description: 'Global ID of the organization to create the application in. ' \
            'Exactly one of `groupPath` or `organizationId` must be provided.'

        argument :name, GraphQL::Types::String,
          required: true,
          description: copy_field_description(::Types::Cd::ApplicationType, :name)

        argument :description, GraphQL::Types::String,
          required: false,
          description: copy_field_description(::Types::Cd::ApplicationType, :description)

        field :application, ::Types::Cd::ApplicationType,
          null: true,
          description: 'Application created by the mutation.'

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

          response = ::Cd::Applications::CreateService
            .new(parent: parent, current_user: current_user, params: args)
            .execute

          {
            application: response.success? ? response.payload[:application] : nil,
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
      end
    end
  end
end
