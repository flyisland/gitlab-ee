# frozen_string_literal: true

module Gitlab
  module ChatopsMessage
    class IssueMessage < ::Integrations::ChatMessage::IssueMessage
      include MessageHelper

      def attachments
        opened_issue? ? limit_output(description) : nil
      end

      private

      def message
        ::Kernel.format(s_("JH|CHAT_MESSAGE|[%{project_link}] Issue %{issue_link} **%{state}** by %{username}"),
          project_link: project_link,
          issue_link: issue_link,
          state: state == 'opened' ? _('Opened') : _('Closed'),
          username: strip_markup(user_combined_name))
      end
    end
  end
end
