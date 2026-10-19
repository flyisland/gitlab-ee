# frozen_string_literal: true

module Gitlab
  module Dingtalk
    class NotificationCard
      TITLE_LIMIT = 100
      MESSAGE_BYTES_LIMIT = 2048
      URL_LIMIT = 500
      REPLY_PREFIX = 'Re: '

      def initialize(title:, url: nil, project: nil, reason: nil, excerpt: nil)
        @title = title
        @url = url
        @project = project
        @reason = reason
        @excerpt = excerpt
      end

      def to_h
        title = display_title
        # Same order as the WeCom and Feishu cards: title, excerpt, project, reason.
        text = [title, @excerpt, project_row, reason_row].select(&:present?).map { |value| escape(value) }.join("\n\n")

        card = {
          title: title,
          markdown: '',
          single_title: s_('JH|DingTalk|View in JiHu GitLab'),
          single_url: @url.presence || ::Gitlab.config.gitlab.url
        }

        if card[:single_url].length > URL_LIMIT
          raise AppResponse::PermanentError, 'DingTalk notification URL is too long'
        end

        bytes_available = MESSAGE_BYTES_LIMIT - ::Gitlab::Json.generate(msgtype: 'action_card',
          action_card: card).bytesize
        raise AppResponse::PermanentError, 'DingTalk notification is too large' if bytes_available < 6

        card[:markdown] = text.truncate_bytes([1000, bytes_available / 2].min)
        card
      end

      private

      # The mail subject threads a conversation, so it repeats the project and may carry a Re: prefix.
      def display_title
        text = @title.to_s.strip.delete_prefix(REPLY_PREFIX)
        text = text.delete_prefix("#{@project} | ") if @project.present?

        text.truncate(TITLE_LIMIT)
      end

      def project_row
        format(s_('JH|DingTalk|Project: %{project}'), project: @project) if @project.present?
      end

      def reason_row
        format(s_('JH|DingTalk|Reason: %{reason}'), reason: reason_label) if reason_label.present?
      end

      def reason_label
        case @reason
        when ::NotificationReason::ASSIGNED then s_('JH|DingTalk|Assigned to you')
        when ::NotificationReason::REVIEW_REQUESTED then s_('JH|DingTalk|Review requested')
        when ::NotificationReason::MENTIONED then s_('JH|DingTalk|You were mentioned')
        when ::NotificationReason::SUBSCRIBED then s_('JH|DingTalk|Subscribed')
        end
      end

      def escape(value)
        CGI.escapeHTML(value.to_s.gsub(/[[:cntrl:]]/, ' ')).gsub(/([\\`*_{}\[\]()#+.!|>-])/) do |character|
          "\\#{character}"
        end
      end
    end
  end
end
