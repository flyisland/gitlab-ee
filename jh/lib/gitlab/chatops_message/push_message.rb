# frozen_string_literal: true

module Gitlab
  module ChatopsMessage
    class PushMessage < ::Integrations::ChatMessage::PushMessage
      include MessageHelper

      COMMIT_LIMITATION = 5

      private

      def message
        if new_branch?
          ::Kernel.format(s_("JH|CHAT_MESSAGE|%{username} pushed new %{ref_type} %{ref_link} to %{project_link}"),
            username: strip_markup(user_combined_name),
            ref_type: ref_type_text,
            ref_link: ref_link,
            project_link: project_link)
        elsif removed_branch?
          ::Kernel.format(s_("JH|CHAT_MESSAGE|%{username} removed %{ref_type} %{ref} from %{project_link}"),
            username: strip_markup(user_combined_name),
            ref_type: ref_type_text,
            ref: ref,
            project_link: project_link)
        else
          ::Kernel.format(s_("JH|CHAT_MESSAGE|%{username} pushed to %{ref_type} %{ref_link} of " \
            "%{project_link} (%{compare_link})"),
            username: strip_markup(user_combined_name),
            ref_type: ref_type_text,
            ref_link: ref_link,
            project_link: project_link,
            compare_link: compare_link)
        end
      end

      def compare_link
        link(_('Compare changes'), compare_url)
      end

      def commit_messages
        list = commits.first(COMMIT_LIMITATION).map { |commit| compose_commit_message(commit) }

        if commits.count > COMMIT_LIMITATION
          list << ::Kernel.format(s_("JH|CHAT_MESSAGE|At most %{number} commits of the merge request are listed " \
            "for your reference."),
            number: COMMIT_LIMITATION)
        end

        list.join("\n")
      end
    end
  end
end
