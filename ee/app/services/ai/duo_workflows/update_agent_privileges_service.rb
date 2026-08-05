# frozen_string_literal: true

module Ai
  module DuoWorkflows
    class UpdateAgentPrivilegesService
      def initialize(workflow:, current_user:, agent_privileges: nil, pre_approved_agent_privileges: nil)
        @workflow = workflow
        @agent_privileges = agent_privileges
        @pre_approved_agent_privileges = pre_approved_agent_privileges
        @current_user = current_user
      end

      def execute
        unless @current_user.can?(:update_duo_workflow, @workflow)
          return error_response("Can not update workflow", :unauthorized)
        end

        update_agent_privileges
      end

      private

      def update_agent_privileges
        @workflow.agent_privileges = @agent_privileges if @agent_privileges
        @workflow.pre_approved_agent_privileges = @pre_approved_agent_privileges if @pre_approved_agent_privileges

        if @workflow.save
          ServiceResponse.success(
            payload: { workflow: @workflow },
            message: "Agent privileges updated successfully"
          )
        else
          error_response("Failed to update agent privileges: #{@workflow.errors.full_messages.join(', ')}")
        end
      end

      def error_response(message, reason = :bad_request)
        ServiceResponse.error(message: message, reason: reason)
      end
    end
  end
end
