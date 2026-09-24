# frozen_string_literal: true

module Gitlab
  module Dingtalk
    class Formatter
      def initialize(params)
        @params = params
      end

      def response_body(message)
        formatted = case message[:type]
                    when :text
                      { msgtype: 'text', text: { content: message[:content] } }
                    when :markdown
                      { msgtype: "markdown", markdown: { title: message[:title], text: message[:content] } }
                    else
                      {}
                    end

        add_at_user_info(formatted)
      end

      def response_text_body(text)
        response_body(type: :text, content: text)
      end

      private

      def add_at_user_info(message)
        {
          at: {
            atUserIds: [at_user_id],
            isAtAll: false
          }
        }.merge(message)
      end

      def group_message?
        @params[:data]['conversationType'] == '2'
      end

      def at_user_id
        @params[:data]['senderStaffId']
      end
    end
  end
end
