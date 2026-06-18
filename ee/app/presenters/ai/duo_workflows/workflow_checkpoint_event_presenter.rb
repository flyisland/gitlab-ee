# frozen_string_literal: true

module Ai
  module DuoWorkflows
    class WorkflowCheckpointEventPresenter < Gitlab::View::Presenter::Delegated
      presents ::Ai::DuoWorkflows::Checkpoint, as: :event

      DuoMessage = Struct.new(:content, :message_type, :message_sub_type, :status, :tool_info,
        :timestamp, :correlation_id, :role, :message_id, :additional_context,
        :component_name, :subsession_id, keyword_init: true)

      # Categories that are internal metadata envelopes, not user-visible context
      # items, and therefore not registered in AiAdditionalContextCategory enum.
      INTERNAL_CONTEXT_CATEGORIES = %w[orbit_context].freeze

      def workflow_status
        event.workflow.status
      end

      def workflow_goal
        event.workflow.goal
      end

      def workflow_definition
        event.workflow.workflow_definition
      end

      def workflow_summary
        event.workflow.summary
      end

      def execution_status
        graph_state = event.checkpoint.dig('channel_values', 'status')
        return graph_state unless graph_state.nil? || graph_state == 'Not Started'

        event.workflow.human_status_name.titleize
      end

      def duo_messages
        checkpoint = event.checkpoint
        return [] unless checkpoint

        ui_chat_log = checkpoint.dig('channel_values', 'ui_chat_log')
        return [] unless ui_chat_log.is_a?(Array)

        ui_chat_log.map do |message|
          msg = message.slice(
            'content', 'message_type', 'message_sub_type', 'status', 'tool_info',
            'timestamp', 'correlation_id', 'role', 'message_id', 'additional_context',
            'component_name', 'subsession_id'
          )

          if msg['additional_context'].is_a?(Array)
            msg['additional_context'] = msg['additional_context'].reject do |ctx|
              INTERNAL_CONTEXT_CATEGORIES.include?(ctx['category'])
            end
          end

          DuoMessage.new(**msg.symbolize_keys)
        end
      end
    end
  end
end
