# frozen_string_literal: true

module MergeRequests
  class ExecuteMergeRequestReadyWorker
    include Gitlab::EventStore::Subscriber

    data_consistency :sticky
    feature_category :code_suggestions
    idempotent!

    def handle_event(event)
      merge_request = MergeRequest.find_by_id(event.data[:merge_request_id])

      unless merge_request
        logger.info(structured_payload(message: 'Merge request not found.',
          merge_request_id: event.data[:merge_request_id]))
        return
      end

      project = merge_request.target_project

      current_user = User.find_by_id(event.data[:current_user_id])

      unless current_user
        logger.info(structured_payload(message: 'User not found.',
          current_user_id: event.data[:current_user_id]))
        return
      end

      execute_flow_triggers(merge_request, project, current_user)
    end

    private

    def execute_flow_triggers(merge_request, project, current_user)
      flow_triggers = project.ai_flow_triggers.triggered_on(:merge_request_ready)

      return unless flow_triggers.exists?

      flow_triggers.each do |trigger|
        ::Ai::FlowTriggers::RunService.new(
          project: project,
          current_user: current_user,
          flow_trigger: trigger,
          resource: merge_request
        ).execute({
          input: merge_request.iid.to_s,
          event: :merge_request_ready
        })
      rescue StandardError => error
        Gitlab::ErrorTracking.track_exception(error,
          flow_trigger_id: trigger.id,
          merge_request_id: merge_request.id,
          project_id: project.id
        )
      end
    end
  end
end
