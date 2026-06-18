# frozen_string_literal: true

module BranchRules
  module ExternalStatusChecks
    class DestroyService < BaseService
      private

      def authorized?
        can?(current_user, :delete_external_status_check, branch_rule)
      end

      def execute_on_branch_rule
        ::ExternalStatusChecks::DestroyService.new(
          container: project,
          current_user: current_user
        ).execute(external_status_check, skip_authorization: true)
      end
      alias_method :execute_on_all_branches_rule, :execute_on_branch_rule

      def external_status_check
        @external_status_check ||= project.external_status_checks.find(params[:id])
      end
    end
  end
end
