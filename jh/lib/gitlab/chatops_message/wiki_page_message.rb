# frozen_string_literal: true

module Gitlab
  module ChatopsMessage
    class WikiPageMessage < ::Integrations::ChatMessage::WikiPageMessage
      include MessageHelper

      def attachments
        limit_output(description)
      end

      private

      def message
        ::Kernel.format(s_('JH|CHAT_MESSAGE|%{username} %{action} %{wiki_page_link} (%{diff_link}) ' \
          'in %{project_link}: *%{title}*'),
          username: strip_markup(user_combined_name),
          action: action_text,
          wiki_page_link: wiki_page_link,
          diff_link: diff_link,
          project_link: project_link,
          title: strip_markup(title))
      end

      def action_text
        action == 'created' ? _('Created') : _('Edited') # not typo, reuse upstream msgid
      end

      def diff_link
        link(_('Compare changes'), diff_url)
      end

      def wiki_page_link
        link(_('wiki page'), wiki_page_url)
      end
    end
  end
end
