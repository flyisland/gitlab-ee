# frozen_string_literal: true

module WorkItems
  module Callbacks
    class AgentPlan < Base
      ALLOWED_PARAMS = %i[content].freeze

      def before_create
        handle_agent_plan_change unless excluded_in_new_type?
      end

      def before_update
        if excluded_in_new_type?
          work_item.agent_plan.destroy! if work_item.agent_plan.present?
          return
        end

        handle_agent_plan_change
      end

      private

      def handle_agent_plan_change
        return unless params.key?(:content)
        return unless has_permission?(:update_work_item)

        agent_plan = work_item.agent_plan || work_item.build_agent_plan
        agent_plan.content = params[:content]

        raise_error(agent_plan.errors.full_messages.join(', ')) unless agent_plan.valid?
      end
    end
  end
end
