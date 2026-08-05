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
          if work_item.agent_plan.present?
            work_item.agent_plan.destroy!
            @agent_plan_event = ::Gitlab::WorkItems::Instrumentation::EventActions::AGENT_PLAN_DESTROY
          end

          return
        end

        handle_agent_plan_change
      end

      def after_save_commit
        return unless @agent_plan_event

        ::Gitlab::WorkItems::Instrumentation::TrackingService.new(
          work_item: work_item,
          current_user: current_user,
          event: @agent_plan_event,
          extra_properties: {
            source: ::Gitlab::WorkItems::Instrumentation::TrackingService.current_source
          }
        ).execute
      end

      private

      def handle_agent_plan_change
        return unless params.key?(:content)
        return unless has_permission?(:update_work_item)

        agent_plan = work_item.agent_plan || work_item.build_agent_plan
        plan_existed = agent_plan.persisted?
        content_changed = agent_plan.content != params[:content]
        agent_plan.content = params[:content]

        raise_error(agent_plan.errors.full_messages.join(', ')) unless agent_plan.valid?

        @agent_plan_event = if !plan_existed
                              ::Gitlab::WorkItems::Instrumentation::EventActions::AGENT_PLAN_CREATE
                            elsif content_changed
                              ::Gitlab::WorkItems::Instrumentation::EventActions::AGENT_PLAN_UPDATE
                            end
      end
    end
  end
end
