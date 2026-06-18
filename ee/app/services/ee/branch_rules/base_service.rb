# frozen_string_literal: true

module EE
  module BranchRules
    module BaseService
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      prepended do
        delegate :approval_project_rules, :external_status_checks, to: :branch_rule, allow_nil: true
        private :approval_project_rules, :external_status_checks
      end

      private

      override :execute_on_branch_rule_type
      def execute_on_branch_rule_type
        return execute_on_all_protected_branches_rule if branch_rule.is_a?(::Projects::AllProtectedBranchesRule)

        super
      end

      def execute_on_all_protected_branches_rule
        missing_method_error('execute_on_all_protected_branches_rule')
      end
    end
  end
end
