# frozen_string_literal: true

module Gitlab
  module ChatopsCommands
    class IssueComment < IssueCommand
      def self.match(text)
        /\Aissue\s+comment\s+#{Issue.reference_prefix}?(?<iid>\d+)\n*(?<note_body>(.|\n)*)/.match(text)
      end

      def self.help_message
        'issue comment (id) *`⇧ Shift`*+*`↵ Enter`* (comment)'
      end

      def execute(match)
        note_body = match[:note_body].to_s.strip
        issue = find_by_iid(match[:iid])

        return ::Gitlab::ChatopsCommands::Presenters::Helper.not_found_issue(match[:iid]) unless issue
        return ::Gitlab::ChatopsCommands::Presenters::Helper.access_denied unless can_create_note?(issue)

        note = create_note(issue: issue, note: note_body)

        if note.persisted?
          presenter(note).present
        elsif success_quick_actions?(note)
          presenter(note).present_quick_actions
        else
          replace_quick_action_error(note)
          presenter(note).display_errors(s_("JH|Chatops|Failed to create the comment:"))
        end
      end

      private

      def replace_quick_action_error(note)
        # app/services/notes/create_service.rb:97, failed comment will contains both commands_only and commands
        return unless note.errors.has_key?(:commands_only) && note.errors.has_key?(:commands)

        note.errors.delete(:commands_only)
        note.errors.delete(:commands)
        note.errors.add(:base, s_("JH|Chatops|Failed to apply quick commands."))
      end

      def success_quick_actions?(note)
        # app/controllers/concerns/notes_actions.rb:63 to detect command success
        note.errors.present? && note.errors.attribute_names == [:commands_only, :command_names]
      end

      def can_create_note?(issue)
        Ability.allowed?(current_user, :create_note, issue)
      end

      def create_note(issue:, note:)
        note_params = { noteable: issue, note: note }
        ::Notes::CreateService.new(project, current_user, note_params).execute
      end

      def presenter(note)
        Gitlab::ChatopsCommands::Presenters::IssueComment.new(note)
      end
    end
  end
end
