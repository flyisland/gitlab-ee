# frozen_string_literal: true

module EE
  module Users
    module ParticipableService
      extend ::Gitlab::Utils::Override

      override :user_as_hash
      def user_as_hash(user)
        super.merge(user_disabled_fields(user))
      end

      override :org_user_detail_as_hash
      def org_user_detail_as_hash(detail)
        super.merge(user_disabled_fields(detail.user))
      end

      def user_disabled_fields(user)
        result = agent_status_check.execute(user)

        {
          disabled: result.disabled?,
          disabled_reason: result.disabled_reason
        }
      end

      private

      def agent_status_check
        @agent_status_check ||= ::Ai::Agents::CheckAgentStatusService.new(current_user)
      end
    end
  end
end
