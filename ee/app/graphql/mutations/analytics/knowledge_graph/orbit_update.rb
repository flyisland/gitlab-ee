# frozen_string_literal: true

module Mutations
  module Analytics
    module KnowledgeGraph
      class OrbitUpdate < BaseMutation
        graphql_name 'OrbitUpdate'

        authorize_granular_token permissions: :update_knowledge_graph_setting, boundary_argument: :group_path,
          boundary_type: :group

        argument :group_path, GraphQL::Types::ID,
          required: true,
          description: 'Full path of the group to update.'

        argument :enabled, GraphQL::Types::Boolean,
          required: true,
          description: 'Whether to enable or disable the Knowledge Graph for the group.'

        field :group, ::Types::GroupType,
          null: true,
          description: 'Group after mutation.'

        def ready?(**args)
          raise_resource_not_available_error! unless ::Analytics::KnowledgeGraph.enabled_for?(current_user)

          super
        end

        def resolve(group_path:, enabled:)
          group = ::Group.find_by_full_path(group_path)
          raise_resource_not_available_error! unless group
          raise_resource_not_available_error! if enabled && plan_tier_access_missing?(group)

          result = ::Analytics::KnowledgeGraph::ToggleNamespaceService.new(
            group: group,
            current_user: current_user,
            enabled: enabled
          ).execute

          raise_resource_not_available_error! if result.error? && result.reason == :forbidden

          {
            group: result.success? ? group : nil,
            errors: result.success? ? [] : [result.message]
          }
        end

        private

        def plan_tier_access_missing?(group)
          license = ::Analytics::KnowledgeGraph::OrbitLicense

          !license.promo_gate_enabled?(group) && !license.available_for?(current_user)
        end
      end
    end
  end
end
