# frozen_string_literal: true

module Ai
  module Messaging
    module Adapters
      # Delivers the UX for AI flows triggered by @mentioning a service account
      # in a note. Two surfaces share one note lifecycle (started note -> reply,
      # destroyed on completion); they differ only in who authors the notes:
      #
      #   * @GitLabDuo MR mention (AssistantFlowHandler, via Base#trigger):
      #     authored by the Duo code-review bot.
      #
      #   * Duo Developer @mention (Notes::PostProcessService, via
      #     Base#with_lifecycle_hooks): authored by the flow-trigger SA.
      #
      # Both surfaces log session start and session end on the item's activity
      # log via the framework's default system notes (CreateWorkflowService and
      # UpdateWorkflowStatusService).
      #
      class GitlabDuoNote < Base
        FLOW_CONFIG_ID = 'gitlab_duo_mention_assistant'
        FLOW_CONFIG_SCHEMA_VERSION = 'v1'
        FLOW_VERSION = 'v1'

        def self.adapter_key
          'gitlab_duo_note'
        end

        def self.for_note(note, note_author_id:)
          new(note_id: note.id, note_author_id: note_author_id)
        end

        def self.from_callback_context(ctx)
          new(
            note_id: ctx['note_id'],
            note_author_id: ctx['note_author_id']
          )
        end

        def initialize(note_id:, note_author_id:)
          @note_id = note_id
          @note_author_id = note_author_id
        end

        def on_request_received
          note = find_note(@note_id)
          return ServiceResponse.error(message: 'Note not found') unless note
          return ServiceResponse.error(message: 'Noteable not found') unless note.noteable

          ServiceResponse.success
        end

        def on_flow_enqueued(callback_context:, workflow:)
          note = find_note(callback_context['note_id'])
          author = note_author(callback_context)
          return unless note&.noteable && author

          started_note = ::SystemNotes::IssuablesService.new(
            noteable: note.noteable,
            container: note.project,
            author: author
          ).duo_mention_started(workflow, note.discussion)

          return unless started_note&.persisted?

          workflow.update_column(
            :messaging_callback_context,
            (workflow.messaging_callback_context || {}).merge('started_note_id' => started_note.id)
          )
        end

        # Persisted on the workflow; CallbackWorker rebuilds the adapter from it.
        def build_callback_context
          {
            'adapter' => self.class.adapter_key,
            'note_id' => @note_id,
            'note_author_id' => @note_author_id
          }.compact
        end

        def deliver_result(callback_context:, message:)
          destroy_started_note(callback_context)
          create_note_on(callback_context, message)
        end

        def deliver_error(callback_context:, error:)
          destroy_started_note(callback_context)
          create_note_on(callback_context, error_text(error))
        end

        private

        def find_note(note_id)
          ::Note.find_by_id(note_id)
        end

        def note_author(ctx)
          ::User.find_by_id(ctx['note_author_id'])
        end

        def create_note_on(callback_context, content)
          return if content.blank?

          note = find_note(callback_context['note_id'])
          author = note_author(callback_context)
          return unless note&.noteable && author

          # A composite-identity service account's permissions are evaluated
          # against a linked human; terminal delivery runs in CallbackWorker with
          # no request identity, so without this link the SA cannot post the
          # reply. Link it to the original mentioner, mirroring the composite
          # token the legacy self-post path relied on. (No-op for @GitLabDuo,
          # whose bot author is not composite-enforced.)
          link_composite_identity!(author, note.author)

          ::Notes::CreateService.new(
            note.project,
            author,
            noteable: note.noteable,
            note: content,
            in_reply_to_discussion_id: note.discussion_id
          ).execute
        end

        def destroy_started_note(callback_context)
          note_id = callback_context['started_note_id']
          return unless note_id

          ::Note.find_by_id(note_id)&.destroy
        end

        def error_text(error)
          case error
          when :service_account_error
            ::Ai::CodeReviewMessages.missing_service_account_error
          when :execute_workflow_failed
            s_("DuoCodeReview|Failed to start the Duo workflow. Please try again.")
          when :flow_failed
            s_("DuoCodeReview|Something went wrong while running the task. Please try again.")
          when :no_response
            s_("DuoCodeReview|The workflow completed but no response was produced. Please try again.")
          else
            s_("DuoCodeReview|Something went wrong. Please try again.")
          end
        end
      end
    end
  end
end
