# frozen_string_literal: true

module Gitlab
  module Wecom
    class Formatter
      # Wecom only support 3 colors now
      TEMPLATE_THEMES = {
        ::Gitlab::ChatopsMessage::MessageHelper::MESSAGE_THEMES[:success] => 'info',
        ::Gitlab::ChatopsMessage::MessageHelper::MESSAGE_THEMES[:warning] => 'warning',
        ::Gitlab::ChatopsMessage::MessageHelper::MESSAGE_THEMES[:error] => 'warning',
        ::Gitlab::ChatopsMessage::MessageHelper::MESSAGE_THEMES[:cancel] => 'comment',
        ::Gitlab::ChatopsMessage::MessageHelper::MESSAGE_THEMES[:running] => 'info'
      }.freeze

      def initialize(params)
        @params = params
      end

      def respond_notification
        Gitlab::Json.generate({
          msgtype: "markdown",
          markdown: {
            content: message_body
          }
        })
      end

      private

      def message
        @params[:message]
      end

      def message_body
        result = []
        result << message_head
        result << message_summary
        result << message_items
        result.join("\n")
      end

      def message_head
        "# <font color=\"#{TEMPLATE_THEMES[message.template_theme]}\">" \
          "#{s_('JH|CHAT_MESSAGE|JiHu GitLab Notification')}</font>"
      end

      def message_summary
        message.pretext.presence || ''
      end

      def message_items
        message.attachments.present? ? "> #{message.attachments}" : ''
      end
    end
  end
end
