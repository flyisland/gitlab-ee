# frozen_string_literal: true

module Ai
  module FlowTriggers
    class CreateNoteService
      include ::Ai::Catalog::Loggable

      attr_reader :project, :resource, :author, :discussion

      def initialize(project:, resource:, author:, discussion: nil)
        @project = project
        @resource = resource
        @author = author
        @discussion = discussion
      end

      def execute(params)
        note = create_note

        unless note.persisted?
          ai_catalog_logger.error(
            message: 'Failed to create processing note',
            noteable_type: resource.class.name,
            noteable_id: resource.id,
            errors: note.errors.full_messages.join(', ')
          )
        end

        response, workflow = yield(params.merge(discussion_id: note.discussion_id))

        update_note(note, response, workflow)

        response
      end

      private

      def create_note
        note = s_('AiFlowTriggers|🔄 Processing the request...')

        ::Notes::CreateService.new(
          project,
          author,
          note: note,
          noteable: resource,
          in_reply_to_discussion_id: discussion&.id
        ).execute
      end

      def update_note(note, response, workflow)
        return unless note.persisted?

        updated_message =
          if response.success?
            link_start = format('<a href="%{url}" target="_blank" rel="noopener noreferrer">'.html_safe,
              url: "#{Gitlab::Routing.url_helpers.project_automate_agent_sessions_url(project)}/#{workflow.id}")
            # We already sanitize names, but as an added safety, it's a good idea to sanitize this input here as well.
            format(s_(
              "AiFlowTriggers|✅ %{flow_name} has started. You can view progress %{link_start}here%{link_end}."
            ), link_start: link_start, link_end: '</a>'.html_safe, flow_name: html_escape(author.name))
          else
            format(s_("AiFlowTriggers|❌ Could not start processing due to this error: %{error}"),
              error: response.message)
          end

        return if note.update(note: updated_message)

        ai_catalog_logger.error(
          message: 'Failed to update processing note',
          note_id: note.id,
          errors: note.errors.full_messages.join(', ')
        )
      end
    end
  end
end
