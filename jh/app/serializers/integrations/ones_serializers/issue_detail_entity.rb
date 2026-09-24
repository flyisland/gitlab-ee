# frozen_string_literal: true

module Integrations
  module OnesSerializers
    class IssueDetailEntity < IssueEntity
      expose :description_html do |item|
        sanitize(item['description'])
      end

      expose :due_date do |item|
        Time.at(item['deadline']).strftime("%F") if item['deadline'].present?
      end

      expose :comments do |item|
        item['comments'].map do |comment|
          {
            id: comment['uuid'],
            created_at: date_time_at(comment['send_time']),
            body_html: sanitize(comment['text'] || s_("JH|OnesIntegration|Attachment")),
            author: user_info(comment['user'])
          }
        end
      end
    end
  end
end
