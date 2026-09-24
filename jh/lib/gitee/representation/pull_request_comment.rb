# frozen_string_literal: true

module Gitee
  module Representation
    class PullRequestComment < IssueComment
      def iid
        raw['id']
      end

      def file_path
        raw['path']
      end

      def author_name
        author['name']
      end

      def inline?
        raw['comment_type'] == 'diff_comment'
      end

      def has_parent?
        !raw['in_reply_to_id'].nil?
      end

      def parent_id
        raw['in_reply_to_id']
      end

      def new_pos
        raw['new_line']
      end

      def old_pos
        raw['old_line']
      end

      private

      def author
        raw.fetch('user', {})
      end
    end
  end
end
