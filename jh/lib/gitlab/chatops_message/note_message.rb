# frozen_string_literal: true

module Gitlab
  module ChatopsMessage
    class NoteMessage < ::Integrations::ChatMessage::NoteMessage
      include MessageHelper

      def attachments
        limit_output(note)
      end

      private

      def message
        action = link(::Kernel.format(s_('JH|commented on %{link_to_project}'), link_to_project: target), note_url)
        ::Kernel.format(s_('JH|CHAT_MESSAGE|%{username} %{action} in %{project_link}: *%{title}*'),
          username: strip_markup(user_combined_name),
          # reuse upstream message id
          action: action,
          project_link: project_link,
          title: strip_markup(formatted_title))
      end

      def create_issue_note(issue)
        [_('issue') + " #{Issue.reference_prefix}#{issue[:iid]}", issue[:title]]
      end

      def create_commit_note(commit)
        [::Kernel.format(_('commit %{commit_id}'), commit_id: Commit.truncate_sha(commit[:id])), commit[:message]]
      end

      def create_merge_note(merge_request)
        [_('merge request') + " #{MergeRequest.reference_prefix}#{merge_request[:iid]}", merge_request[:title]]
      end

      def create_snippet_note(snippet)
        [s_('JH|snippet') + " #{Snippet.reference_prefix}#{snippet[:id]}", snippet[:title]]
      end
    end
  end
end
