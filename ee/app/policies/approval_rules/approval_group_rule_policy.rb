# frozen_string_literal: true

module ApprovalRules
  class ApprovalGroupRulePolicy < BasePolicy
    delegate { @subject.group }

    rule { locked_approvers_rules & ~admin }.policy do
      prevent :update_approval_rule
      prevent :delete_approval_rule
    end
  end
end
