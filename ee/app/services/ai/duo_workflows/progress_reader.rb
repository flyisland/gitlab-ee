# frozen_string_literal: true

module Ai
  module DuoWorkflows
    # Reads a workflow's live progress as a cursor-based delta of ui_chat_log
    # entries, so consumers stream "what's new since I last looked" without
    # knowing how checkpoints are stored.
    #
    # The delta is the flow's own ui_chat_log entry format (the shape the web UI
    # renders): the flow decides what to show, the sink decides how. Backed by
    # the full checkpoint today; when delta checkpoints land, only this changes.
    class ProgressReader
      # cursor is opaque to callers: persisted (e.g. in messaging_callback_context)
      # and passed back on the next read.
      Delta = Data.define(:messages, :cursor) do
        def empty?
          messages.empty?
        end
      end

      def delta_since(workflow, cursor:)
        cursor ||= {}
        checkpoint = workflow.checkpoints.latest

        return Delta.new(messages: [], cursor: cursor) if checkpoint.nil?
        return Delta.new(messages: [], cursor: cursor) if checkpoint.thread_ts == cursor['thread_ts']

        log = checkpoint.ui_chat_log

        # Cumulative log, so an unknown cursor (nil, or a message_id dropped by a
        # compaction) falls back to the whole log.
        start = next_index_after(log, cursor['message_id'])

        Delta.new(
          messages: log[start..] || [],
          cursor: {
            'thread_ts' => checkpoint.thread_ts,
            'message_id' => log.last&.dig('message_id') || cursor['message_id']
          }
        )
      end

      private

      def next_index_after(log, message_id)
        return 0 if message_id.nil?

        idx = log.index { |entry| entry['message_id'] == message_id }
        idx ? idx + 1 : 0
      end
    end
  end
end
