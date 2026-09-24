# frozen_string_literal: true

module Gitee
  module Representation
    class IssueComment < Representation::Base
      def iid
        raw['id']
      end

      def author
        user['name']
      end

      def note
        raw.fetch('body', nil)
      end

      def created_at
        raw['created_at']
      end

      def updated_at
        raw['updated_at']
      end

      def has_parent?
        !raw['in_reply_to_id'].nil?
      end

      def parent_id
        raw['in_reply_to_id']
      end

      private

      def user
        raw.fetch('user', {})
      end
    end
  end
end
