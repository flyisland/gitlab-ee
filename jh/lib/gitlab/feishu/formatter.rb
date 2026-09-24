# frozen_string_literal: true

module Gitlab
  module Feishu
    class Formatter
      # https://open.feishu.cn/document/ukTMukTMukTM/ukTNwUjL5UDM14SO1ATN
      TEMPLATE_THEMES = {
        ::Gitlab::ChatopsMessage::MessageHelper::MESSAGE_THEMES[:success] => 'green',
        ::Gitlab::ChatopsMessage::MessageHelper::MESSAGE_THEMES[:warning] => 'yellow',
        ::Gitlab::ChatopsMessage::MessageHelper::MESSAGE_THEMES[:error] => 'red',
        ::Gitlab::ChatopsMessage::MessageHelper::MESSAGE_THEMES[:cancel] => 'grey',
        ::Gitlab::ChatopsMessage::MessageHelper::MESSAGE_THEMES[:running] => 'blue'
      }.freeze

      def initialize(params)
        @params = params
      end

      def response_text_body(text)
        response_body(type: :text, content: text)
      end

      def response_body(message)
        case message[:type]
        when :markdown
          msg_type = "interactive"
          content = interactive_content(message[:title], message[:content])
        else
          msg_type = "text"
          content = text_content(message[:content])
        end

        {
          receive_id: receive_id,
          msg_type: msg_type,
          content: Gitlab::Json.generate(content)
        }
      end

      def respond_notification(feishu_chat_id)
        Gitlab::Json.generate({
          receive_id: feishu_chat_id,
          content: Gitlab::Json.generate(message_body),
          msg_type: "interactive"
        })
      end

      private

      def interactive_content(title, body)
        mention = group_message? ? %(<at id="#{sender_id}"></at>) : ""
        message_content = <<~CONTENT
            #{body}
            #{mention}
        CONTENT

        {
          header: {
            title: {
              tag: "plain_text",
              content: title
            }
          },
          elements: [
            { tag: "markdown", content: message_content }
          ]
        }
      end

      def text_content(body)
        mention = group_message? ? %(<at user_id="#{sender_id}"></at>) : ""
        message_content = <<~CONTENT
            #{body}
            #{mention}
        CONTENT

        {
          text: message_content
        }
      end

      def message_body
        {
          "header" => {
            "title" => {
              "tag" => "markdown",
              "content" => s_('JH|CHAT_MESSAGE|JiHu GitLab Notification')
            },
            "template" => TEMPLATE_THEMES[message.template_theme]
          },
          "elements" => elements
        }
      end

      def elements
        result = []
        result << { "tag" => "markdown", "content" => message.pretext } if message.pretext.present?
        result << { "tag" => "markdown", "content" => message.attachments } if message.attachments.present?
        result
      end

      def message
        @params[:message]
      end

      def receive_id
        data.dig(:event, :message, :chat_id)
      end

      def sender_id
        data.dig(:event, :sender, :sender_id, :user_id)
      end

      def data
        @params[:data] || {}
      end

      def group_message?
        data.dig(:event, :message, :chat_type) == "group"
      end
    end
  end
end
