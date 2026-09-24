# frozen_string_literal: true

module Integrations
  module LigaaiSerializers
    class IssueDetailEntity < IssueEntity
      expose :description_html do |item|
        sanitize(item['description'])
      end

      expose :comments do |item|
        item['comments'].map do |comment|
          {
            id: comment['commentId']&.to_i,
            created_at: parsed_date(item['createTime']),
            body_html: sanitize(comment['content']),
            author: user_info(comment['commentUser'])
          }
        end
      end
    end
  end
end
