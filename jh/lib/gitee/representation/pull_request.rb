# frozen_string_literal: true

module Gitee
  module Representation
    class PullRequest < Representation::Base
      def author
        raw.fetch('user', {}).fetch('name', nil)
      end

      def description
        raw['body']
      end

      def iid
        raw['number']
      end

      def state
        raw['state'] == 'open' ? 'opened' : raw['state']
      end

      def created_at
        raw['created_at']
      end

      def updated_at
        raw['updated_at']
      end

      def title
        raw['title']
      end

      def draft?
        raw['draft']
      end

      def milestone
        raw['milestone']['title'] if raw['milestone'].present?
      end

      def source_branch_name
        source_branch.fetch('ref', nil)
      end

      def source_branch_sha
        source_branch.fetch('sha', nil)
      end

      def target_branch_name
        target_branch.fetch('ref', nil)
      end

      def target_branch_sha
        target_branch.fetch('sha', nil)
      end

      def labels
        raw['labels'].map { |label| label['name'] }
      end

      private

      def source_branch
        raw['head']
      end

      def target_branch
        raw['base']
      end
    end
  end
end
