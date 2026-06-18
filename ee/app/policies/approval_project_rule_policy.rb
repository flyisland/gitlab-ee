# frozen_string_literal: true

class ApprovalProjectRulePolicy < BasePolicy
  delegate { @subject.project }

  rule { locked_approvers_rules & ~admin }.policy do
    prevent :update_approval_rule
    prevent :delete_approval_rule
  end
end
