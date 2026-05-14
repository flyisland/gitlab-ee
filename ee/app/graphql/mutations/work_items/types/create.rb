# frozen_string_literal: true

module Mutations
  module WorkItems
    module Types
      class Create < BaseMutation
        graphql_name 'WorkItemTypeCreate'

        include Mutations::ResolvesGroup
        include Gitlab::Utils::StrongMemoize

        authorize :create_work_item_type

        field :work_item_type, ::Types::WorkItems::TypeType,
          null: true,
          description: 'Work item type that was created.'

        argument :name, GraphQL::Types::String,
          required: true,
          description: 'Name for the work item type.'

        argument :icon_name, GraphQL::Types::String,
          required: true,
          description: "Icon name for the work item type. Use the `workItemTypeIconDefinitions` query to " \
            "retrieve the list of available icon names."

        argument :full_path, GraphQL::Types::String,
          required: false,
          description: 'Full path of the root group.'

        def resolve(full_path: nil, **args)
          namespace = authorized_find!(full_path: full_path)

          response = ::WorkItems::Types::CreateService.new(
            container: namespace,
            current_user: current_user,
            params: args
          ).execute

          if response.success?
            response_object = response.payload[:work_item_type]
            context[:resource_parent] = response.payload[:resource_parent]
          end

          response_errors = response.error? ? Array(response.errors) : []

          {
            work_item_type: response_object,
            errors: response_errors
          }
        end

        private

        def find_object(full_path: nil)
          if full_path.present?
            resolve_group(full_path: full_path)
          else
            context[:current_organization]
          end
        end
      end
    end
  end
end
