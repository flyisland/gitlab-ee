# frozen_string_literal: true

module Ai
  module Notes
    # Extracts and formats the conversation history from a note's discussion
    # thread for use as context in AI goals / prompts.
    #
    # Only human (non-system) notes are included (system notes like label
    # changes, assignments, etc. are filtered out). Notes are ordered
    # chronologically and formatted as XML-like <message> blocks.
    #
    # When the discussion exceeds +max_notes+, older messages are omitted
    # with a notice so the AI knows the history is truncated.
    #
    # Usage:
    #   context = Ai::Notes::ConversationContextBuilder.new(note).build
    #   # => "<message author=\"@alice\">\nHello\n</message>\n..."
    #
    class ConversationContextBuilder
      DEFAULT_MAX_NOTES = 15

      # @param note [Note] the triggering note whose discussion to extract
      # @param max_notes [Integer] maximum number of recent notes to include
      def initialize(note, max_notes: DEFAULT_MAX_NOTES)
        @note = note
        @max_notes = max_notes
      end

      # @return [String] formatted conversation context
      def build
        notes = fetch_discussion_notes
        truncated = notes.size > max_notes
        recent_notes = notes.last(max_notes)

        messages = recent_notes.map { |n| format_note(n) }.join("\n")

        if truncated
          "<!-- Earlier messages omitted. " \
            "Use GitLab tools to fetch the full discussion if needed. -->\n#{messages}"
        else
          messages
        end
      end

      private

      attr_reader :note, :max_notes

      def fetch_discussion_notes
        # Scope by noteable (issue/MR) *before* discussion_id so the planner can
        # use index_notes_on_noteable_id_and_noteable_type_system_author_id and
        # stay bounded. Filtering on discussion_id alone is unsafe: some
        # discussion_ids are "collision buckets" shared by tens of thousands of
        # unrelated notes, forcing a full sort of every matching row.
        ::Note
          .with_noteable_type(note.noteable_type)
          .with_noteable_ids(note.noteable_id)
          .with_discussion_ids(note.discussion_id)
          .user
          .inc_author
          .order_created_at_id_asc
          .last(max_notes + 1)
      end

      def format_note(note)
        username = note.author&.username || 'unknown'

        "<message id=\"#{note.id}\" author=\"@#{username}\">\n#{note.note}\n</message>"
      end
    end
  end
end
