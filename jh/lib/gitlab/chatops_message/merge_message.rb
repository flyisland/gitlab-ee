# frozen_string_literal: true

module Gitlab
  module ChatopsMessage
    class MergeMessage < ::Integrations::ChatMessage::MergeMessage
      include MessageHelper

      def template_theme
        case action
        when 'unapproved', 'unapproval'
          MESSAGE_THEMES[:error]
        when 'close'
          MESSAGE_THEMES[:cancel]
        when 'lock'
          MESSAGE_THEMES[:warning]
        else
          MESSAGE_THEMES[:success]
        end
      end

      private

      def message
        ::Kernel.format(s_('JH|CHAT_MESSAGE|%{username} %{state_or_action_text} merge request ' \
          '%{merge_request_link} in %{project_link}'),
          username: strip_markup(user_combined_name),
          state_or_action_text: state_or_action_text,
          merge_request_link: merge_request_link,
          project_link: project_link)
      end

      def state_or_action_text
        case action
        when 'approved'
          _('Approved')
        when 'unapproved'
          s_('JH|CHAT_MESSAGE|unapproved')
        when 'approval'
          s_('JH|CHAT_MESSAGE|added their approval to')
        when 'unapproval'
          s_('JH|CHAT_MESSAGE|removed their approval from')
        when 'open'
          _('Opened')
        when 'reopen'
          _('Reopen')
        when 'close'
          _('Closed')
        when 'merge'
          _('Merged')
        when 'lock'
          _('Locked')
        end
      end
    end
  end
end
