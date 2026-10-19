# frozen_string_literal: true

module Ai
  module DuoWorkflows
    # Spans every workplan run: a new run never reposts a cancelled run's open questions.
    # Question rules mirror ResumeWorkplanService (!252945), but a question only counts as
    # answered once its thread is resolved, not when the resume would forward a reply.
    class WorkplanQuestions
      include Gitlab::Utils::StrongMemoize

      Question = Struct.new(:note, :answered, keyword_init: true)

      def initialize(work_item, current_user)
        @work_item = work_item
        @current_user = current_user
      end

      # Separates "no flow has ever run" from "a run asked nothing", which callers
      # report as null and an empty list respectively.
      def any_flow_ran?
        workplan_workflows.exists?
      end
      strong_memoize_attr :any_flow_ran?

      # Ordered oldest first, so the client can step through them in the order they were asked.
      def questions
        answered = resolved_discussion_ids.to_set

        question_notes.map do |note|
          Question.new(note: note, answered: answered.include?(note.discussion_id))
        end
      end
      strong_memoize_attr :questions

      def open_count
        questions.count { |question| !question.answered }
      end

      # Every flow note counts: asks and progress comments go through the same tool and
      # service account, so nothing marks them apart. Once per thread, the rest are follow-ups.
      def question_notes
        flow_notes.select { |note| readable?(note) }.uniq(&:discussion_id)
      end
      strong_memoize_attr :question_notes

      private

      attr_reader :work_item, :current_user

      # Filtered because the client would otherwise scroll to a note that is never rendered.
      # Per-note NotePolicy is an N+1; the internal rule is the only one that can differ here.
      def readable?(note)
        return true unless note.confidential?

        internal_notes_readable?
      end

      def internal_notes_readable?
        Ability.allowed?(current_user, :read_internal_note, work_item)
      end
      strong_memoize_attr :internal_notes_readable?

      def flow_notes
        ::Note.id_in(::Ai::DuoWorkflows::WorkflowNote.link_type_created.for_workflows(workplan_workflows).select(:note_id))
          .order_created_at_id_asc
          .select(:id, :type, :discussion_id, :confidential)
          .to_a
      end
      strong_memoize_attr :flow_notes

      def workplan_workflows
        work_item.duo_workflows
          .with_workflow_definition(::Ai::Catalog::FoundationalFlow.workplan_v1.reference)
      end

      # A flat note is not resolvable, so it stays open.
      def resolved_discussion_ids
        return [] if question_notes.empty?

        ::Note.resolvable
          .with_discussion_ids(question_notes.map(&:discussion_id))
          .group(:discussion_id)
          .having('COUNT(*) = COUNT(resolved_at)')
          .pluck(:discussion_id) # rubocop:disable Database/AvoidUsingPluckWithoutLimit -- bounded by one work item's question threads
      end
    end
  end
end
