# frozen_string_literal: true

module MergeRequests
  module V2ApprovalRules
    class ParamsFilteringService < ApprovalRules::ParamsFilteringService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute
        params.delete(:v2_approval_rules_attributes) unless current_user.can?(:update_approvers, target)

        filter_non_user_defined_rules if updating?
        params.delete(:reset_approval_rules_to_defaults) unless updating?

        return params unless params.key?(:v2_approval_rules_attributes)

        params[:v2_approval_rules_attributes]&.each do |v2_rule_attributes|
          handle_rule(v2_rule_attributes)
        end

        params
      end
    end
  end
end
