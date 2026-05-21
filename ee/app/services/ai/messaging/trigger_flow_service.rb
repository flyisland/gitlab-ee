# frozen_string_literal: true

module Ai
  module Messaging
    class TriggerFlowService
      include ::Gitlab::Utils::StrongMemoize

      WORKFLOW_DEFINITION_REF = 'developer/v1'

      def initialize(current_user:, goal:, callback_context:)
        @current_user = current_user
        @goal = goal
        @callback_context = callback_context
      end

      # @return [ServiceResponse] with payload { workflow:, workload_id: } on success
      def execute
        namespace = resolve_namespace
        return error('No default Duo namespace configured', :namespace_not_configured) unless namespace

        unless flow_enabled_for?(namespace)
          return error(
            "The #{WORKFLOW_DEFINITION_REF} flow is not enabled for this namespace. " \
              'Ask a group owner to enable it in the Duo Agent Platform settings.',
            :flow_not_enabled
          )
        end

        project_result = resolve_workspace_project(namespace)
        return project_result unless project_result.success?

        project = project_result.payload[:project]

        service_account = resolve_service_account(namespace)
        return error('Could not resolve service account', :service_account_error) unless service_account

        member_result = ensure_service_account_access(project, service_account)
        unless member_result.success?
          return error('Could not grant service account access to workspace project',
            :service_account_error)
        end

        execute_workflow(project, service_account)
      end

      private

      attr_reader :current_user, :goal, :callback_context

      def resolve_namespace
        current_user.default_duo_namespace&.root_ancestor
      end

      def workflow_definition
        ::Ai::Catalog::FoundationalFlow[WORKFLOW_DEFINITION_REF]
      end
      strong_memoize_attr :workflow_definition

      def flow_enabled_for?(namespace)
        catalog_item = workflow_definition&.catalog_item
        return false unless catalog_item

        namespace.duo_foundational_flows_enabled &&
          namespace.enabled_flow_catalog_item_ids.include?(catalog_item.id)
      end

      def resolve_workspace_project(namespace)
        WorkspaceProjectService.new(namespace: namespace, current_user: current_user).execute
      end

      def resolve_service_account(namespace)
        catalog_item = workflow_definition&.catalog_item
        return unless catalog_item

        result = ::Ai::Catalog::ItemConsumers::ResolveServiceAccountService.new(
          container: namespace,
          item: catalog_item
        ).execute

        return unless result.success?

        result.payload[:service_account]
      end

      def ensure_service_account_access(project, service_account)
        ::Ai::ServiceAccountMemberAddService.new(project, service_account).execute
      end

      # Delegates workflow creation and execution to the existing catalog
      # ExecuteWorkflowService, which handles privileges, token generation,
      # and workflow start with the proven production path.
      def execute_workflow(project, service_account)
        result = ::Ai::Catalog::ExecuteWorkflowService.new(
          current_user,
          container: project,
          goal: goal,
          service_account: service_account,
          flow_definition: WORKFLOW_DEFINITION_REF,
          source_branch: project.default_branch_or_main,
          messaging_callback_context: callback_context
        ).execute

        if result.success?
          result
        else
          error(Array(result.message).to_sentence, :execute_workflow_failed)
        end
      end

      def error(message, reason)
        ServiceResponse.error(message: message, reason: reason)
      end
    end
  end
end
