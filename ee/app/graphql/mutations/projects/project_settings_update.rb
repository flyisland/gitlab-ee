# frozen_string_literal: true

module Mutations
  module Projects
    class ProjectSettingsUpdate < BaseMutation
      graphql_name 'ProjectSettingsUpdate'

      include FindsProject
      include Gitlab::Utils::StrongMemoize

      authorize :admin_project
      authorize_granular_token permissions: :update_project, boundary_argument: :full_path, boundary_type: :project

      argument :full_path,
        GraphQL::Types::ID,
        required: true,
        description: 'Full Path of the project the settings belong to.'

      argument :duo_features_enabled,
        GraphQL::Types::Boolean,
        required: false,
        description: 'Indicates whether GitLab Duo features are enabled for the project.'

      argument :tool_approval_for_session_enabled,
        GraphQL::Types::Boolean,
        required: false,
        description: 'Indicates whether tool approval for Duo Workflow sessions is enabled for the project.'

      argument :duo_context_exclusion_settings,
        Types::Projects::Input::DuoContextExclusionSettingsInputType,
        required: false,
        description: 'Settings for excluding files from Duo context.'

      argument :web_based_commit_signing_enabled,
        GraphQL::Types::Boolean,
        required: false,
        description: 'Indicates whether web-based commit signing is enabled for the project.',
        experiment: { milestone: '18.2' }

      field :project_settings,
        Types::Projects::SettingType,
        null: false,
        description: 'Project settings after mutation.'

      argument :duo_sast_vr_workflow_enabled,
        GraphQL::Types::Boolean,
        required: false,
        description: 'Indicates whether SAST Vulnerability Resolution workflow is enabled for the project.'

      def resolve(full_path:, **args)
        raise raise_resource_not_available_error! unless allowed?

        project = find_object(full_path)
        raise_resource_not_available_error! unless can_access?(project, args)

        # Process duo_context_exclusion_settings to convert it to a hash if present
        if args[:duo_context_exclusion_settings].present?
          args[:duo_context_exclusion_settings] = args[:duo_context_exclusion_settings].to_h
        end

        args.compact!

        raise Gitlab::Graphql::Errors::ArgumentError, 'Must provide at least one argument' if args.empty?

        ::Projects::UpdateService.new(project, current_user, { project_setting_attributes: args }).execute

        {
          project_settings: project.project_setting,
          errors: errors_on_object(project.project_setting)
        }
      end

      private

      def allowed?
        return true if ::Gitlab::Saas.feature_available?(:duo_chat_on_saas)
        return true if ::Gitlab::Saas.feature_available?(:repositories_web_based_commit_signing)
        return false unless ::License.feature_available?(:code_suggestions)

        ::GitlabSubscriptions::AddOnPurchase.active_duo_add_ons_exist?(:instance)
      end

      def can_access?(project, args)
        return false unless project

        return true if current_user.can?(:admin_project, project)

        Feature.enabled?(:update_sast_vr_setting_permission, project) &&
          args.keys == [:duo_sast_vr_workflow_enabled] &&
          current_user.can?(:update_sec_ai_workflow_settings, project)
      end
    end
  end
end
