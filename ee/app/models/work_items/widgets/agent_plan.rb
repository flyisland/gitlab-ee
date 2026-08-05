# frozen_string_literal: true

module WorkItems
  module Widgets
    class AgentPlan < Base
      delegate :content, :content_html, to: :agent_plan_record, allow_nil: true

      private

      def agent_plan_record
        work_item.agent_plan
      end
    end
  end
end
