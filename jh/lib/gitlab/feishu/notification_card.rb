# frozen_string_literal: true

module Gitlab
  module Feishu
    # Mirrors the WeCom notification card: icon and product name, title, excerpt, project and reason,
    # and a link to the notification target.
    class NotificationCard
      TITLE_LIMIT = 100
      REPLY_PREFIX = 'Re: '

      def initialize(title:, url: nil, project: nil, reason: nil, excerpt: nil, icon_key: nil)
        @title = title
        @url = url
        @project = project
        @reason = reason
        @excerpt = excerpt
        @icon_key = icon_key
      end

      def to_h
        {
          config: { wide_screen_mode: true, enable_forward: false },
          card_link: { url: link },
          header: header,
          elements: elements
        }
      end

      private

      # The notification title stays in the header because Feishu previews a card by its header title.
      def header
        {
          title: plain_text(title),
          subtitle: plain_text(s_('JH|Feishu|JiHu GitLab')),
          icon: (@icon_key ? { img_key: @icon_key } : nil),
          template: 'blue'
        }.compact
      end

      def elements
        rows = []
        rows << text_row(@excerpt) if @excerpt.present?
        rows << text_row(format(s_('JH|Feishu|Project: %{project}'), project: @project)) if @project.present?
        rows << text_row(format(s_('JH|Feishu|Reason: %{reason}'), reason: reason_label)) if reason_label.present?
        rows << {
          tag: 'action',
          actions: [{ tag: 'button', text: plain_text(s_('JH|Feishu|View in GitLab')), type: 'primary', url: link }]
        }
        rows
      end

      # The mail subject threads a conversation, so it repeats the project and may carry a Re: prefix.
      def title
        text = @title.to_s.strip.delete_prefix(REPLY_PREFIX)
        text = text.delete_prefix("#{@project} | ") if @project.present?

        text.truncate(TITLE_LIMIT)
      end

      def link
        @url.presence || ::Gitlab.config.gitlab.url
      end

      def reason_label
        case @reason
        when ::NotificationReason::ASSIGNED then s_('JH|Feishu|Assigned to you')
        when ::NotificationReason::REVIEW_REQUESTED then s_('JH|Feishu|Review requested')
        when ::NotificationReason::MENTIONED then s_('JH|Feishu|You were mentioned')
        when ::NotificationReason::SUBSCRIBED then s_('JH|Feishu|Subscribed')
        end
      end

      def text_row(text)
        { tag: 'div', text: plain_text(text) }
      end

      def plain_text(text)
        { tag: 'plain_text', content: text }
      end
    end
  end
end
