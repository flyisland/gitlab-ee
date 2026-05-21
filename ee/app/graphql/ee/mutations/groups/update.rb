# frozen_string_literal: true

module EE
  module Mutations
    module Groups
      module Update
        extend ActiveSupport::Concern

        prepended do
          argument :duo_features_enabled, GraphQL::Types::Boolean,
            required: false,
            description: copy_field_description(::Types::GroupType, :duo_features_enabled)
          argument :lock_duo_features_enabled, GraphQL::Types::Boolean,
            required: false,
            description: copy_field_description(::Types::GroupType, :lock_duo_features_enabled)
          argument :web_based_commit_signing_enabled,
            GraphQL::Types::Boolean,
            required: false,
            description: copy_field_description(::Types::GroupType, :web_based_commit_signing_enabled),
            experiment: { milestone: '18.2' }
          argument :tool_approval_for_session_enabled, GraphQL::Types::Boolean,
            required: false,
            description: copy_field_description(::Types::GroupType, :tool_approval_for_session_enabled)
          argument :lock_tool_approval_for_session_enabled, GraphQL::Types::Boolean,
            required: false,
            description: copy_field_description(::Types::GroupType, :lock_tool_approval_for_session_enabled)
          argument :built_in_project_templates_enabled, GraphQL::Types::Boolean,
            required: false,
            description: 'Indicates whether built-in project templates are available for new projects in the group.',
            experiment: { milestone: '19.0' }
          argument :lock_built_in_project_templates_enabled, GraphQL::Types::Boolean,
            required: false,
            description: 'Indicates if the built-in project templates enabled setting is enforced for all subgroups.',
            experiment: { milestone: '19.0' }
        end
      end
    end
  end
end
